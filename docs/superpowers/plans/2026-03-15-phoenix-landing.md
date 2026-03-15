# Phoenix Landing Page Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert static HTML landing page into a Phoenix LiveView app with form submissions saved to PostgreSQL, email+Telegram notifications, hardcoded-auth admin panel, and Fly.io deployment.

**Architecture:** Phoenix 1.7 LiveView app. Landing page is a single LiveView with all 14 sections. Consultation form submits via LiveView, saves to PostgreSQL via Ecto, then fires async email (Swoosh) + Telegram (Req HTTP) notifications. Admin panel uses Plug-based hardcoded auth with session cookie. Fly.io deployment via Dockerfile.

**Tech Stack:** Elixir 1.17, Phoenix 1.7.19, LiveView, Ecto + PostgreSQL, Swoosh (email), Req (Telegram HTTP), Tailwind CSS (Phoenix built-in), Fly.io

---

## Environment Notes

- PostgreSQL 12 installed but **clusters are down** — must start before `mix ecto.create`
- `flyctl` not installed — must install before deploy step
- Phoenix installer 1.7.19 available via `mix phx.new`

---

## File Structure

After scaffolding with `mix phx.new`, these are the files we **create or modify** beyond the default:

```
painting_crew/
├── lib/
│   ├── painting_crew/
│   │   ├── submissions/              # Submissions context
│   │   │   ├── submission.ex          # Ecto schema + changeset
│   │   │   └── submissions.ex         # Context module (create, list, etc.)
│   │   └── notifier.ex               # Email + Telegram notification logic
│   ├── painting_crew_web/
│   │   ├── components/
│   │   │   └── layouts/
│   │   │       ├── root.html.heex     # MODIFY: lang="ru", fonts, grain/stripe CSS
│   │   │       └── app.html.heex      # MODIFY: remove default Phoenix chrome
│   │   ├── live/
│   │   │   ├── landing_live.ex        # Main landing page LiveView
│   │   │   └── landing_live.html.heex # All 14 sections template
│   │   ├── controllers/
│   │   │   ├── admin_controller.ex    # Admin login/logout + submissions list
│   │   │   └── admin_html/
│   │   │       ├── login.html.heex    # Login form
│   │   │       └── index.html.heex    # Submissions table
│   │   ├── plugs/
│   │   │   └── admin_auth.ex          # Plug: check session for hardcoded creds
│   │   └── router.ex                  # MODIFY: routes
│   └── painting_crew/mailer.ex        # EXISTS from generator, configure Swoosh
├── priv/
│   └── repo/migrations/
│       └── *_create_submissions.exs   # Migration
├── config/
│   ├── config.exs                     # MODIFY: mailer, telegram config
│   ├── dev.exs                        # MODIFY: mailer to Swoosh.Adapters.Local
│   ├── runtime.exs                    # MODIFY: prod DB, SMTP, Telegram env vars
│   └── test.exs                       # MODIFY: test mailer adapter
├── test/
│   ├── painting_crew/
│   │   ├── submissions_test.exs       # Context tests
│   │   └── notifier_test.exs          # Notifier tests
│   └── painting_crew_web/
│       ├── live/
│       │   └── landing_live_test.exs  # LiveView tests
│       └── controllers/
│           └── admin_controller_test.exs
├── assets/
│   ├── js/app.js                      # MODIFY: add dark mode + scroll observer hooks
│   └── css/app.css                    # MODIFY: custom styles (grain, stripes, speed-bar)
├── fly.toml                           # Fly.io config
├── Dockerfile                         # EXISTS from generator, verify
└── .env.example                       # Document required env vars
```

---

## Chunk 1: Project Scaffolding & Database

### Task 1: Scaffold Phoenix project

**Files:**
- Create: entire Phoenix project structure in `/home/zulkris/projects/painting_crew/`

**Prerequisites:** Back up existing files before scaffolding overwrites the directory.

- [ ] **Step 1: Back up existing files**

```bash
cd /home/zulkris/projects/painting_crew
mkdir -p /tmp/painting_crew_backup
cp index.html pokrasochnaya_brigada_landing.md CLAUDE.md /tmp/painting_crew_backup/
cp -r .claude /tmp/painting_crew_backup/
cp -r docs /tmp/painting_crew_backup/
```

- [ ] **Step 2: Generate Phoenix project**

```bash
cd /home/zulkris/projects
mix phx.new painting_crew --app painting_crew --module PaintingCrew
```

When prompted "Fetch and install dependencies?", answer `Y`.

Expected: Phoenix project scaffolded with LiveView, Tailwind, Ecto.

- [ ] **Step 3: Restore backed-up files**

```bash
cp /tmp/painting_crew_backup/index.html /home/zulkris/projects/painting_crew/index.html
cp /tmp/painting_crew_backup/pokrasochnaya_brigada_landing.md /home/zulkris/projects/painting_crew/
cp /tmp/painting_crew_backup/CLAUDE.md /home/zulkris/projects/painting_crew/
cp -r /tmp/painting_crew_backup/.claude /home/zulkris/projects/painting_crew/
cp -r /tmp/painting_crew_backup/docs /home/zulkris/projects/painting_crew/
```

- [ ] **Step 4: Verify project compiles**

```bash
cd /home/zulkris/projects/painting_crew
mix compile
```

Expected: Compilation succeeds with no errors.

- [ ] **Step 5: Commit scaffolding**

```bash
git add -A
git commit -m "feat: scaffold Phoenix 1.7 project with LiveView and Tailwind"
```

---

### Task 2: Start PostgreSQL and create database

- [ ] **Step 1: Start PostgreSQL cluster**

```bash
sudo pg_ctlcluster 12 main start
```

Expected: PostgreSQL 12 cluster starts on port 5434.

- [ ] **Step 2: Configure dev.exs for correct port**

Modify `config/dev.exs` — update the Repo config to use port 5434 (since cluster 12 runs there):

```elixir
config :painting_crew, PaintingCrew.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5434,
  database: "painting_crew_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

Also update `config/test.exs`:

```elixir
config :painting_crew, PaintingCrew.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5434,
  database: "painting_crew_test#{System.get_env("MIX_TEST_PARTITION")},
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
```

- [ ] **Step 3: Ensure postgres user/password exist**

```bash
sudo -u postgres psql -p 5434 -c "ALTER USER postgres PASSWORD 'postgres';"
```

- [ ] **Step 4: Create database**

```bash
cd /home/zulkris/projects/painting_crew
mix ecto.create
```

Expected: `The database for PaintingCrew.Repo has been created`

- [ ] **Step 5: Verify Phoenix starts**

```bash
mix phx.server &
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://localhost:4000
kill %1
```

Expected: HTTP 200

- [ ] **Step 6: Commit database config**

```bash
git add config/dev.exs config/test.exs
git commit -m "fix: configure PostgreSQL port 5434 for local cluster"
```

---

### Task 3: Create Submissions schema and migration

**Files:**
- Create: `lib/painting_crew/submissions/submission.ex`
- Create: `lib/painting_crew/submissions/submissions.ex`
- Create: `priv/repo/migrations/*_create_submissions.exs`
- Create: `test/painting_crew/submissions_test.exs`

- [ ] **Step 1: Write the test for Submissions context**

Create `test/painting_crew/submissions_test.exs`:

```elixir
defmodule PaintingCrew.SubmissionsTest do
  use PaintingCrew.DataCase, async: true

  alias PaintingCrew.Submissions
  alias PaintingCrew.Submissions.Submission

  @valid_attrs %{name: "Иван", phone: "+79001234567", email: "ivan@example.com"}
  @invalid_attrs %{name: nil, phone: nil, email: nil}

  describe "create_submission/1" do
    test "with valid data creates a submission" do
      assert {:ok, %Submission{} = sub} = Submissions.create_submission(@valid_attrs)
      assert sub.name == "Иван"
      assert sub.phone == "+79001234567"
      assert sub.email == "ivan@example.com"
    end

    test "with missing required fields returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Submissions.create_submission(@invalid_attrs)
    end

    test "email is optional" do
      attrs = Map.delete(@valid_attrs, :email)
      assert {:ok, %Submission{}} = Submissions.create_submission(attrs)
    end
  end

  describe "list_submissions/0" do
    test "returns all submissions ordered by newest first" do
      {:ok, sub1} = Submissions.create_submission(@valid_attrs)
      {:ok, sub2} = Submissions.create_submission(%{@valid_attrs | name: "Петр"})
      result = Submissions.list_submissions()
      assert length(result) == 2
      assert hd(result).id == sub2.id
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

```bash
mix test test/painting_crew/submissions_test.exs
```

Expected: compilation errors — modules don't exist yet.

- [ ] **Step 3: Generate migration**

```bash
mix ecto.gen.migration create_submissions
```

Edit the generated migration file:

```elixir
defmodule PaintingCrew.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :name, :string, null: false
      add :phone, :string, null: false
      add :email, :string

      timestamps(type: :utc_datetime)
    end
  end
end
```

- [ ] **Step 4: Create Submission schema**

Create `lib/painting_crew/submissions/submission.ex`:

```elixir
defmodule PaintingCrew.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :name, :string
    field :phone, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:name, :phone, :email])
    |> validate_required([:name, :phone])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:phone, min: 5, max: 30)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "некорректный email")
  end
end
```

- [ ] **Step 5: Create Submissions context**

Create `lib/painting_crew/submissions/submissions.ex`:

```elixir
defmodule PaintingCrew.Submissions do
  import Ecto.Query
  alias PaintingCrew.Repo
  alias PaintingCrew.Submissions.Submission

  def create_submission(attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  def list_submissions do
    Submission
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
```

- [ ] **Step 6: Run migration and tests**

```bash
mix ecto.migrate
mix test test/painting_crew/submissions_test.exs
```

Expected: All 4 tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/painting_crew/submissions/ priv/repo/migrations/ test/painting_crew/submissions_test.exs
git commit -m "feat: add Submissions context with schema, migration, and tests"
```

---

## Chunk 2: Landing Page LiveView

### Task 4: Set up root layout and custom CSS

**Files:**
- Modify: `lib/painting_crew_web/components/layouts/root.html.heex`
- Modify: `lib/painting_crew_web/components/layouts/app.html.heex`
- Modify: `assets/css/app.css`

- [ ] **Step 1: Update root layout**

Replace `lib/painting_crew_web/components/layouts/root.html.heex` with:
- `lang="ru"` on html tag
- Add `class="scroll-smooth"` to html tag
- Add Google Fonts `<link>` for Unbounded + Onest in `<head>`
- Keep existing Phoenix head content (csrf, live_title, app.css, app.js)

Key head additions:
```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Unbounded:wght@400;600;800&family=Onest:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

- [ ] **Step 2: Strip app.html.heex to bare minimum**

Replace `lib/painting_crew_web/components/layouts/app.html.heex` — remove all default Phoenix chrome (header, nav), just render:

```heex
<main>
  <.flash_group flash={@flash} />
  {@inner_content}
</main>
```

- [ ] **Step 3: Configure Tailwind for custom fonts and brand colours**

Modify `assets/tailwind.config.js` — add to `theme.extend`:

```js
colors: {
  primary: {
    50:  '#eef4fb',
    100: '#d9e8f7',
    200: '#b1ceee',
    300: '#75a8de',
    400: '#3a82cc',
    500: '#1c61b0',
    600: '#174f90',
    700: '#133f73',
    800: '#184675',
    900: '#0a2147',
    950: '#051025',
    DEFAULT: '#184675',
  },
  accent: {
    50:  '#fff0f0',
    100: '#ffd6d6',
    200: '#ffadad',
    300: '#ff7070',
    400: '#ff3333',
    500: '#f70101',
    600: '#cc0101',
    700: '#a30000',
    800: '#7a0000',
    900: '#520000',
    950: '#290000',
    DEFAULT: '#f70101',
  },
},
fontFamily: {
  display: ['Unbounded', 'sans-serif'],
  sans: ['Onest', 'system-ui', 'sans-serif'],
},
```

- [ ] **Step 4: Add custom CSS to app.css**

Append to `assets/css/app.css` the custom styles from `index.html`: `.hero-stripes`, `.grain::after`, `.speed-bar` animation, `.faq-icon` transition, `.pricing-glow`. Copy these directly from the `<style>` block in `index.html`.

- [ ] **Step 5: Commit**

```bash
git add lib/painting_crew_web/components/layouts/ assets/css/app.css assets/tailwind.config.js
git commit -m "feat: configure root layout, Tailwind brand colours, custom CSS"
```

---

### Task 5: Create landing page LiveView

**Files:**
- Create: `lib/painting_crew_web/live/landing_live.ex`
- Create: `lib/painting_crew_web/live/landing_live.html.heex`
- Modify: `lib/painting_crew_web/router.ex`
- Modify: `assets/js/app.js`
- Create: `test/painting_crew_web/live/landing_live_test.exs`

- [ ] **Step 1: Write basic LiveView test**

Create `test/painting_crew_web/live/landing_live_test.exs`:

```elixir
defmodule PaintingCrewWeb.LandingLiveTest do
  use PaintingCrewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "landing page" do
    test "renders hero section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Запуск покрасочной"
      assert html =~ "бригады"
      assert html =~ "под ключ"
    end

    test "renders all major sections", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Для кого это"
      assert html =~ "Сколько можно зарабатывать"
      assert html =~ "Что входит в запуск"
      assert html =~ "Как проходит запуск"
      assert html =~ "Примеры работ"
      assert html =~ "Стартовый комплект"
      assert html =~ "Почему это быстрее"
      assert html =~ "Отзывы и кейсы"
      assert html =~ "Пакеты запуска"
      assert html =~ "Частые вопросы"
      assert html =~ "Получите план запуска"
    end

    test "renders phone number", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "+7 900 654-68-21"
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

```bash
mix test test/painting_crew_web/live/landing_live_test.exs
```

Expected: FAIL — module/route doesn't exist.

- [ ] **Step 3: Create LiveView module**

Create `lib/painting_crew_web/live/landing_live.ex`:

```elixir
defmodule PaintingCrewWeb.LandingLive do
  use PaintingCrewWeb, :live_view

  alias PaintingCrew.Submissions.Submission

  @impl true
  def mount(_params, _session, socket) do
    changeset = Submission.changeset(%Submission{}, %{})

    {:ok,
     socket
     |> assign(:page_title, "Запуск покрасочной бригады под ключ")
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"submission" => params}, socket) do
    changeset =
      %Submission{}
      |> Submission.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("submit", %{"submission" => params}, socket) do
    case PaintingCrew.Submissions.create_submission(params) do
      {:ok, submission} ->
        Task.start(fn -> PaintingCrew.Notifier.notify(submission) end)

        changeset = Submission.changeset(%Submission{}, %{})

        {:noreply,
         socket
         |> put_flash(:info, "Спасибо! Мы свяжемся с вами в течение 24 часов.")
         |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "submission"))
  end
end
```

- [ ] **Step 4: Create the HEEx template**

Create `lib/painting_crew_web/live/landing_live.html.heex`.

Convert all 14 sections from `index.html` to HEEx. Key conversions:
- Replace `class=` HTML with HEEx `class=` (same syntax, just ensure no Elixir conflicts)
- Replace the static `<form>` in section 12 with a LiveView form:

```heex
<.form for={@form} phx-change="validate" phx-submit="submit" class="bg-primary-900/80 backdrop-blur border border-primary-800 rounded-2xl p-6 sm:p-8" aria-label="Форма заявки">
  <div class="grid sm:grid-cols-2 gap-4 mb-4">
    <div>
      <label for="first-name" class="block text-sm font-medium text-primary-200 mb-1">Имя</label>
      <.input field={@form[:name]} type="text" placeholder="Ваше имя" required
        class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-sm" />
    </div>
    <div>
      <label for="phone" class="block text-sm font-medium text-primary-200 mb-1">Телефон</label>
      <.input field={@form[:phone]} type="tel" placeholder="+7 XXX XXX XXXX" required
        class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-sm" />
    </div>
  </div>
  <div class="mb-6">
    <label for="email" class="block text-sm font-medium text-primary-200 mb-1">Email</label>
    <.input field={@form[:email]} type="email" placeholder="you@example.com"
      class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-sm" />
  </div>
  <button type="submit" phx-disable-with="Отправка..."
    class="w-full py-4 rounded-xl bg-accent-600 hover:bg-accent-700 text-white font-bold text-lg transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-primary-950">
    Получить консультацию
  </button>
  <p class="text-center text-xs text-primary-500 mt-3">Свяжемся в течение 24 часов. Без обязательств.</p>
</.form>
```

- Nav section: include sticky header with mobile menu (use Alpine.js-free approach — JS hook or `phx-click` toggle)
- Dark mode: use a JS hook (`DarkMode`) that reads/writes localStorage
- FAQ: use `<details>` elements (native HTML, no JS needed)
- Speed bars: use a JS hook (`SpeedBarObserver`) with IntersectionObserver
- Footer: include copyright year via `<%= DateTime.utc_now().year %>`

**Important:** The template should be the full faithful conversion of all 14 sections from `index.html`. Do not omit any section.

- [ ] **Step 5: Add JS hooks to app.js**

Modify `assets/js/app.js` — add hooks object to LiveSocket:

```js
let Hooks = {}

Hooks.DarkMode = {
  mounted() {
    const root = document.documentElement;
    const saved = localStorage.getItem("theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const theme = saved || (prefersDark ? "dark" : "light");
    this.applyTheme(theme);

    this.el.addEventListener("click", () => {
      const isDark = root.classList.contains("dark");
      const next = isDark ? "light" : "dark";
      localStorage.setItem("theme", next);
      this.applyTheme(next);
    });
  },
  applyTheme(theme) {
    const root = document.documentElement;
    if (theme === "dark") {
      root.classList.add("dark");
      this.el.querySelector("#icon-sun").classList.remove("hidden");
      this.el.querySelector("#icon-moon").classList.add("hidden");
    } else {
      root.classList.remove("dark");
      this.el.querySelector("#icon-sun").classList.add("hidden");
      this.el.querySelector("#icon-moon").classList.remove("hidden");
    }
  }
}

Hooks.MobileMenu = {
  mounted() {
    const menu = document.getElementById("mobile-menu");
    const openIcon = document.getElementById("menu-open");
    const closeIcon = document.getElementById("menu-close");

    this.el.addEventListener("click", () => {
      const expanded = this.el.getAttribute("aria-expanded") === "true";
      this.el.setAttribute("aria-expanded", String(!expanded));
      menu.classList.toggle("hidden");
      openIcon.classList.toggle("hidden");
      closeIcon.classList.toggle("hidden");
    });

    menu.querySelectorAll("a").forEach(link => {
      link.addEventListener("click", () => {
        menu.classList.add("hidden");
        this.el.setAttribute("aria-expanded", "false");
        openIcon.classList.remove("hidden");
        closeIcon.classList.add("hidden");
      });
    });
  }
}

Hooks.SpeedBar = {
  mounted() {
    this.el.style.animationPlayState = "paused";
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.animationPlayState = "running";
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.3 });
    observer.observe(this.el);
  }
}

// Pass hooks to LiveSocket
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})
```

- [ ] **Step 6: Add route**

Modify `lib/painting_crew_web/router.ex`:

```elixir
scope "/", PaintingCrewWeb do
  pipe_through :browser

  live "/", LandingLive
end
```

Remove the default `get "/", PageController, :home` route and the PageController if it exists.

- [ ] **Step 7: Run tests**

```bash
mix test test/painting_crew_web/live/landing_live_test.exs
```

Expected: All 3 tests pass.

- [ ] **Step 8: Visual check — start server and verify responsiveness**

```bash
mix phx.server
```

Manually verify at http://localhost:4000:
- All 14 sections render
- Dark mode toggle works
- Mobile menu works (resize browser to < 768px)
- FAQ accordions expand/collapse
- Speed bars animate on scroll
- Form validates on input
- Layout is responsive at 375px, 768px, 1024px, 1440px widths

- [ ] **Step 9: Commit**

```bash
git add lib/painting_crew_web/live/ lib/painting_crew_web/router.ex assets/js/app.js
git commit -m "feat: landing page LiveView with all 14 sections, form, JS hooks"
```

---

### Task 6: Add form submission test

**Files:**
- Modify: `test/painting_crew_web/live/landing_live_test.exs`

- [ ] **Step 1: Add form submission tests**

Append to `landing_live_test.exs`:

```elixir
describe "consultation form" do
  test "validates required fields on change", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> form("form", submission: %{name: "", phone: ""})
      |> render_change()

    assert html =~ "can&#39;t be blank" or html =~ "не может быть пустым"
  end

  test "submits form successfully", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("form", submission: %{name: "Тест", phone: "+79001234567", email: "t@t.com"})
    |> render_submit()

    flash = assert_redirected(view, ~p"/") || render(view)
    # Check submission was created
    assert [sub] = PaintingCrew.Submissions.list_submissions()
    assert sub.name == "Тест"
    assert sub.phone == "+79001234567"
  end
end
```

- [ ] **Step 2: Run tests**

```bash
mix test test/painting_crew_web/live/landing_live_test.exs
```

Expected: All tests pass (notifier will be stubbed/noop in test).

- [ ] **Step 3: Commit**

```bash
git add test/painting_crew_web/live/landing_live_test.exs
git commit -m "test: add form validation and submission tests for landing page"
```

---

## Chunk 3: Notifications (Email + Telegram)

### Task 7: Create Notifier module

**Files:**
- Create: `lib/painting_crew/notifier.ex`
- Modify: `config/config.exs`
- Modify: `config/dev.exs`
- Modify: `config/runtime.exs`
- Create: `test/painting_crew/notifier_test.exs`

- [ ] **Step 1: Write notifier test**

Create `test/painting_crew/notifier_test.exs`:

```elixir
defmodule PaintingCrew.NotifierTest do
  use PaintingCrew.DataCase, async: true
  import Swoosh.TestAssertions

  alias PaintingCrew.Notifier
  alias PaintingCrew.Submissions.Submission

  @submission %Submission{
    id: 1,
    name: "Тест",
    phone: "+79001234567",
    email: "test@example.com",
    inserted_at: ~U[2026-03-15 12:00:00Z]
  }

  describe "send_email/1" do
    test "sends email with submission details" do
      assert {:ok, _} = Notifier.send_email(@submission)
      assert_email_sent(subject: "Новая заявка: Тест")
    end
  end

  describe "build_telegram_message/1" do
    test "formats submission as text" do
      msg = Notifier.build_telegram_message(@submission)
      assert msg =~ "Тест"
      assert msg =~ "+79001234567"
      assert msg =~ "test@example.com"
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

```bash
mix test test/painting_crew/notifier_test.exs
```

Expected: FAIL — module doesn't exist.

- [ ] **Step 3: Add Req dependency**

Add to `mix.exs` deps (Req is already a transitive dep of Phoenix but add explicitly):

```elixir
{:req, "~> 0.5"}
```

Run `mix deps.get`.

- [ ] **Step 4: Configure Swoosh mailer**

In `config/config.exs`, add:

```elixir
config :painting_crew, PaintingCrew.Mailer,
  adapter: Swoosh.Adapters.SMTP

config :painting_crew, :notifications,
  admin_email: "admin@paintingcrew.com",
  from_email: "noreply@paintingcrew.com",
  telegram_bot_token: "",
  telegram_chat_id: ""
```

In `config/dev.exs`, override mailer:

```elixir
config :painting_crew, PaintingCrew.Mailer, adapter: Swoosh.Adapters.Local
```

In `config/test.exs`, override mailer:

```elixir
config :painting_crew, PaintingCrew.Mailer, adapter: Swoosh.Adapters.Test
```

In `config/runtime.exs`, add for prod:

```elixir
config :painting_crew, :notifications,
  admin_email: System.get_env("ADMIN_EMAIL") || "admin@paintingcrew.com",
  from_email: System.get_env("FROM_EMAIL") || "noreply@paintingcrew.com",
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN") || "",
  telegram_chat_id: System.get_env("TELEGRAM_CHAT_ID") || ""

if config_env() == :prod do
  config :painting_crew, PaintingCrew.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: System.get_env("SMTP_RELAY") || "smtp.gmail.com",
    port: String.to_integer(System.get_env("SMTP_PORT") || "587"),
    username: System.get_env("SMTP_USERNAME"),
    password: System.get_env("SMTP_PASSWORD"),
    tls: :always
end
```

- [ ] **Step 5: Create Notifier module**

Create `lib/painting_crew/notifier.ex`:

```elixir
defmodule PaintingCrew.Notifier do
  import Swoosh.Email
  alias PaintingCrew.Mailer

  def notify(submission) do
    send_email(submission)
    send_telegram(submission)
    :ok
  end

  def send_email(submission) do
    config = Application.get_env(:painting_crew, :notifications, [])
    from = Keyword.get(config, :from_email, "noreply@paintingcrew.com")
    to = Keyword.get(config, :admin_email, "admin@paintingcrew.com")

    email =
      new()
      |> to(to)
      |> from({"Покрасочная бригада", from})
      |> subject("Новая заявка: #{submission.name}")
      |> text_body(build_email_body(submission))

    Mailer.deliver(email)
  end

  def send_telegram(submission) do
    config = Application.get_env(:painting_crew, :notifications, [])
    token = Keyword.get(config, :telegram_bot_token, "")
    chat_id = Keyword.get(config, :telegram_chat_id, "")

    if token != "" and chat_id != "" do
      url = "https://api.telegram.org/bot#{token}/sendMessage"

      Req.post(url,
        json: %{
          chat_id: chat_id,
          text: build_telegram_message(submission),
          parse_mode: "HTML"
        }
      )
    else
      {:ok, :telegram_not_configured}
    end
  end

  def build_telegram_message(submission) do
    """
    <b>Новая заявка с сайта</b>

    <b>Имя:</b> #{submission.name}
    <b>Телефон:</b> #{submission.phone}
    <b>Email:</b> #{submission.email || "—"}
    <b>Время:</b> #{Calendar.strftime(submission.inserted_at, "%d.%m.%Y %H:%M")}
    """
    |> String.trim()
  end

  defp build_email_body(submission) do
    """
    Новая заявка с сайта «Покрасочная бригада»

    Имя: #{submission.name}
    Телефон: #{submission.phone}
    Email: #{submission.email || "—"}
    Время: #{Calendar.strftime(submission.inserted_at, "%d.%m.%Y %H:%M")}
    """
    |> String.trim()
  end
end
```

- [ ] **Step 6: Run tests**

```bash
mix test test/painting_crew/notifier_test.exs
```

Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/painting_crew/notifier.ex config/ mix.exs mix.lock test/painting_crew/notifier_test.exs
git commit -m "feat: add Notifier module with email (Swoosh) and Telegram support"
```

---

## Chunk 4: Admin Panel

### Task 8: Admin auth plug and login

**Files:**
- Create: `lib/painting_crew_web/plugs/admin_auth.ex`
- Create: `lib/painting_crew_web/controllers/admin_controller.ex`
- Create: `lib/painting_crew_web/controllers/admin_html.ex`
- Create: `lib/painting_crew_web/controllers/admin_html/login.html.heex`
- Create: `lib/painting_crew_web/controllers/admin_html/index.html.heex`
- Modify: `lib/painting_crew_web/router.ex`
- Modify: `config/config.exs`
- Modify: `config/runtime.exs`
- Create: `test/painting_crew_web/controllers/admin_controller_test.exs`

- [ ] **Step 1: Write admin tests**

Create `test/painting_crew_web/controllers/admin_controller_test.exs`:

```elixir
defmodule PaintingCrewWeb.AdminControllerTest do
  use PaintingCrewWeb.ConnCase, async: true

  @valid_creds %{"username" => "admin", "password" => "admin"}
  @invalid_creds %{"username" => "admin", "password" => "wrong"}

  describe "GET /admin/login" do
    test "renders login form", %{conn: conn} do
      conn = get(conn, ~p"/admin/login")
      assert html_response(conn, 200) =~ "Вход в админ-панель"
    end
  end

  describe "POST /admin/login" do
    test "with valid creds redirects to admin index", %{conn: conn} do
      conn = post(conn, ~p"/admin/login", @valid_creds)
      assert redirected_to(conn) == ~p"/admin"
    end

    test "with invalid creds re-renders login with error", %{conn: conn} do
      conn = post(conn, ~p"/admin/login", @invalid_creds)
      assert html_response(conn, 200) =~ "Неверный логин или пароль"
    end
  end

  describe "GET /admin (protected)" do
    test "redirects to login when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/admin")
      assert redirected_to(conn) == ~p"/admin/login"
    end

    test "shows submissions when authenticated", %{conn: conn} do
      {:ok, _} = PaintingCrew.Submissions.create_submission(%{
        name: "Тест", phone: "+79001234567"
      })

      conn =
        conn
        |> post(~p"/admin/login", @valid_creds)
        |> get(~p"/admin")

      assert html_response(conn, 200) =~ "Тест"
      assert html_response(conn, 200) =~ "+79001234567"
    end
  end

  describe "DELETE /admin/logout" do
    test "clears session and redirects to login", %{conn: conn} do
      conn =
        conn
        |> post(~p"/admin/login", @valid_creds)
        |> delete(~p"/admin/logout")

      assert redirected_to(conn) == ~p"/admin/login"
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
mix test test/painting_crew_web/controllers/admin_controller_test.exs
```

Expected: FAIL — modules don't exist.

- [ ] **Step 3: Add admin credentials config**

In `config/config.exs`:

```elixir
config :painting_crew, :admin,
  username: "admin",
  password: "admin"
```

In `config/runtime.exs` (inside the `if config_env() == :prod` block):

```elixir
config :painting_crew, :admin,
  username: System.get_env("ADMIN_USERNAME") || "admin",
  password: System.get_env("ADMIN_PASSWORD") || raise("ADMIN_PASSWORD must be set in production")
```

- [ ] **Step 4: Create AdminAuth plug**

Create `lib/painting_crew_web/plugs/admin_auth.ex`:

```elixir
defmodule PaintingCrewWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :admin_authenticated) do
      conn
    else
      conn
      |> put_flash(:error, "Необходима авторизация")
      |> redirect(to: ~p"/admin/login")
      |> halt()
    end
  end

  def authenticate(username, password) do
    config = Application.get_env(:painting_crew, :admin, [])
    expected_user = Keyword.get(config, :username, "admin")
    expected_pass = Keyword.get(config, :password, "admin")

    if Plug.Crypto.secure_compare(username, expected_user) and
       Plug.Crypto.secure_compare(password, expected_pass) do
      :ok
    else
      :error
    end
  end
end
```

- [ ] **Step 5: Create AdminController**

Create `lib/painting_crew_web/controllers/admin_controller.ex`:

```elixir
defmodule PaintingCrewWeb.AdminController do
  use PaintingCrewWeb, :controller

  alias PaintingCrewWeb.Plugs.AdminAuth

  def login_form(conn, _params) do
    render(conn, :login, error: nil)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    case AdminAuth.authenticate(username, password) do
      :ok ->
        conn
        |> put_session(:admin_authenticated, true)
        |> redirect(to: ~p"/admin")

      :error ->
        render(conn, :login, error: "Неверный логин или пароль")
    end
  end

  def index(conn, _params) do
    submissions = PaintingCrew.Submissions.list_submissions()
    render(conn, :index, submissions: submissions)
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/admin/login")
  end
end
```

- [ ] **Step 6: Create AdminHTML module and templates**

Create `lib/painting_crew_web/controllers/admin_html.ex`:

```elixir
defmodule PaintingCrewWeb.AdminHTML do
  use PaintingCrewWeb, :html

  embed_templates "admin_html/*"
end
```

Create `lib/painting_crew_web/controllers/admin_html/login.html.heex`:

```heex
<div class="min-h-screen flex items-center justify-center bg-primary-50 dark:bg-primary-950 px-4">
  <div class="w-full max-w-sm">
    <h1 class="font-display text-2xl font-bold text-center text-primary-900 dark:text-white mb-8">Вход в админ-панель</h1>

    <form method="post" action={~p"/admin/login"} class="bg-white dark:bg-primary-900 rounded-2xl border border-primary-100 dark:border-primary-800 p-6 space-y-4">
      <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

      <%= if @error do %>
        <div class="p-3 rounded-lg bg-accent-50 dark:bg-accent-950/30 border border-accent-200 dark:border-accent-900 text-accent-700 dark:text-accent-300 text-sm">
          <%= @error %>
        </div>
      <% end %>

      <div>
        <label class="block text-sm font-medium text-primary-700 dark:text-primary-300 mb-1">Логин</label>
        <input type="text" name="username" required autocomplete="username"
          class="w-full px-4 py-3 rounded-xl border border-primary-200 dark:border-primary-700 bg-white dark:bg-primary-800 text-primary-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary" />
      </div>

      <div>
        <label class="block text-sm font-medium text-primary-700 dark:text-primary-300 mb-1">Пароль</label>
        <input type="password" name="password" required autocomplete="current-password"
          class="w-full px-4 py-3 rounded-xl border border-primary-200 dark:border-primary-700 bg-white dark:bg-primary-800 text-primary-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary" />
      </div>

      <button type="submit"
        class="w-full py-3 rounded-xl bg-primary hover:bg-primary-700 text-white font-bold text-sm transition-colors">
        Войти
      </button>
    </form>
  </div>
</div>
```

Create `lib/painting_crew_web/controllers/admin_html/index.html.heex`:

```heex
<div class="min-h-screen bg-primary-50 dark:bg-primary-950">
  <header class="bg-white dark:bg-primary-900 border-b border-primary-100 dark:border-primary-800 px-6 py-4 flex items-center justify-between">
    <h1 class="font-display text-lg font-bold text-primary-900 dark:text-white">Заявки</h1>
    <div class="flex items-center gap-4">
      <span class="text-sm text-primary-500">Всего: <%= length(@submissions) %></span>
      <a href={~p"/admin/logout"} data-method="delete" data-csrf={get_csrf_token()}
        class="text-sm text-accent-600 hover:text-accent-700 font-medium">Выйти</a>
    </div>
  </header>

  <div class="max-w-6xl mx-auto px-4 sm:px-6 py-8">
    <%= if @submissions == [] do %>
      <p class="text-center text-primary-400 py-20">Заявок пока нет.</p>
    <% else %>
      <div class="bg-white dark:bg-primary-900 rounded-2xl border border-primary-100 dark:border-primary-800 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-primary-50 dark:bg-primary-800/50">
            <tr>
              <th class="text-left px-6 py-3 font-semibold text-primary-700 dark:text-primary-300">Имя</th>
              <th class="text-left px-6 py-3 font-semibold text-primary-700 dark:text-primary-300">Телефон</th>
              <th class="text-left px-6 py-3 font-semibold text-primary-700 dark:text-primary-300">Email</th>
              <th class="text-left px-6 py-3 font-semibold text-primary-700 dark:text-primary-300">Дата</th>
            </tr>
          </thead>
          <tbody>
            <%= for sub <- @submissions do %>
              <tr class="border-t border-primary-100 dark:border-primary-800 hover:bg-primary-50 dark:hover:bg-primary-800/30">
                <td class="px-6 py-4 font-medium text-primary-900 dark:text-white"><%= sub.name %></td>
                <td class="px-6 py-4 text-primary-600 dark:text-primary-300"><%= sub.phone %></td>
                <td class="px-6 py-4 text-primary-600 dark:text-primary-300"><%= sub.email || "—" %></td>
                <td class="px-6 py-4 text-primary-400"><%= Calendar.strftime(sub.inserted_at, "%d.%m.%Y %H:%M") %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    <% end %>
  </div>
</div>
```

- [ ] **Step 7: Add routes**

Update `lib/painting_crew_web/router.ex`:

```elixir
# Public admin routes (login)
scope "/admin", PaintingCrewWeb do
  pipe_through :browser

  get "/login", AdminController, :login_form
  post "/login", AdminController, :login
end

# Protected admin routes
scope "/admin", PaintingCrewWeb do
  pipe_through [:browser, PaintingCrewWeb.Plugs.AdminAuth]

  get "/", AdminController, :index
  delete "/logout", AdminController, :logout
end
```

- [ ] **Step 8: Run tests**

```bash
mix test test/painting_crew_web/controllers/admin_controller_test.exs
```

Expected: All 5 tests pass.

- [ ] **Step 9: Commit**

```bash
git add lib/painting_crew_web/plugs/ lib/painting_crew_web/controllers/admin* lib/painting_crew_web/router.ex config/ test/painting_crew_web/controllers/
git commit -m "feat: add admin panel with hardcoded auth and submissions table"
```

---

## Chunk 5: Fly.io Deployment

### Task 9: Configure Fly.io deployment

**Files:**
- Modify: `fly.toml` (will be generated by `fly launch`)
- Modify: `config/runtime.exs`
- Create: `.env.example`

- [ ] **Step 1: Install flyctl**

```bash
curl -L https://fly.io/install.sh | sh
```

Add to PATH if needed: `export FLYCTL_INSTALL="/home/zulkris/.fly"` and `export PATH="$FLYCTL_INSTALL/bin:$PATH"`.

- [ ] **Step 2: Authenticate with Fly.io**

```bash
fly auth login
```

Follow browser-based auth flow.

- [ ] **Step 3: Launch Fly app**

```bash
cd /home/zulkris/projects/painting_crew
fly launch --no-deploy
```

This generates `fly.toml` and detects the Phoenix Dockerfile. When prompted:
- App name: `painting-crew` (or similar)
- Region: choose closest (e.g., `ams` for EU)
- PostgreSQL: Yes, create a Fly Postgres cluster
- Redis: No

- [ ] **Step 4: Set secrets**

```bash
fly secrets set \
  SECRET_KEY_BASE=$(mix phx.gen.secret) \
  DATABASE_URL="<from fly pg output>" \
  ADMIN_USERNAME="admin" \
  ADMIN_PASSWORD="<strong-password>" \
  ADMIN_EMAIL="admin@paintingcrew.com" \
  FROM_EMAIL="noreply@paintingcrew.com" \
  TELEGRAM_BOT_TOKEN="<your-bot-token>" \
  TELEGRAM_CHAT_ID="<your-chat-id>" \
  SMTP_RELAY="smtp.gmail.com" \
  SMTP_PORT="587" \
  SMTP_USERNAME="<email>" \
  SMTP_PASSWORD="<app-password>"
```

- [ ] **Step 5: Verify Dockerfile exists and is correct**

Phoenix 1.7 generates a Dockerfile by default. Verify it exists and includes:
- Multi-stage build (build + runtime)
- `mix assets.deploy`
- `mix ecto.migrate` in release

If no release migration step, add to `lib/painting_crew/release.ex`:

```elixir
defmodule PaintingCrew.Release do
  @app :painting_crew

  def migrate do
    load_app()
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

- [ ] **Step 6: Create .env.example**

Create `.env.example`:

```bash
# Database (set by Fly.io automatically)
DATABASE_URL=ecto://user:pass@host/painting_crew_prod

# Phoenix
SECRET_KEY_BASE=

# Admin panel
ADMIN_USERNAME=admin
ADMIN_PASSWORD=

# Email notifications (Swoosh SMTP)
ADMIN_EMAIL=admin@paintingcrew.com
FROM_EMAIL=noreply@paintingcrew.com
SMTP_RELAY=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=

# Telegram notifications
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
```

- [ ] **Step 7: Deploy**

```bash
fly deploy
```

Expected: Build succeeds, app is live at `https://painting-crew.fly.dev` (or chosen name).

- [ ] **Step 8: Run migration on Fly**

```bash
fly ssh console -C "/app/bin/painting_crew eval 'PaintingCrew.Release.migrate()'"
```

- [ ] **Step 9: Verify deployment**

```bash
curl -s -o /dev/null -w "%{http_code}" https://painting-crew.fly.dev
```

Expected: HTTP 200.

- [ ] **Step 10: Commit deployment config**

```bash
git add fly.toml Dockerfile .env.example lib/painting_crew/release.ex
git commit -m "feat: add Fly.io deployment config"
```

---

## Chunk 6: Final Verification

### Task 10: Full test suite and responsiveness check

- [ ] **Step 1: Run full test suite**

```bash
mix test
```

Expected: All tests pass.

- [ ] **Step 2: Check responsiveness manually**

Start dev server: `mix phx.server`

Test at these breakpoints:
- **375px** (mobile): all sections stack vertically, hamburger menu visible, form is usable
- **768px** (tablet): 2-column grids where applicable, nav links visible
- **1024px** (desktop): full layout, all columns rendered
- **1440px** (wide): content centered, max-width respected

Verify:
- [ ] Nav sticky + mobile menu toggle
- [ ] Hero text scales, CTAs stack on mobile
- [ ] Target audience cards: 1 col → 2 col → 4 col
- [ ] Earnings cards: stack on mobile, side-by-side on desktop
- [ ] "What's included" grid: 1 col → 2 col
- [ ] Timeline: readable on all sizes
- [ ] Example cards: 1 col → 3 col
- [ ] Equipment: stacks on mobile
- [ ] Speed bars: full width on all sizes
- [ ] Pricing cards: 1 col → 3 col
- [ ] FAQ: full width, touch-friendly tap targets
- [ ] Form: inputs full width, submit button full width
- [ ] Dark mode works everywhere
- [ ] No horizontal scroll at any breakpoint

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "chore: final verification — all tests pass, responsive layout confirmed"
```
