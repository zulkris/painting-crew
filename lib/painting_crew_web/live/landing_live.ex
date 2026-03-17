defmodule PaintingCrewWeb.LandingLive do
  use PaintingCrewWeb, :live_view

  alias PaintingCrew.Submissions
  alias PaintingCrew.Submissions.Submission

  @impl true
  def mount(_params, _session, socket) do
    changeset = Submissions.change_submission(%Submission{})

    {:ok,
     socket
     |> assign(:page_title, "БригСтарт — Запуск покрасочной бригады под ключ")
     |> assign(:form, to_form(changeset))
     |> assign(:submitted, false)}
  end

  @impl true
  def handle_event("validate", %{"submission" => params}, socket) do
    changeset =
      %Submission{}
      |> Submission.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("submit", %{"submission" => params}, socket) do
    case Submissions.create_submission(params) do
      {:ok, submission} ->
        Task.start(fn -> PaintingCrew.Notifier.notify(submission) end)

        {:noreply,
         socket
         |> assign(:submitted, true)
         |> put_flash(:info, "Заявка отправлена! Свяжемся в течение 24 часов.")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.landing_page form={@form} submitted={@submitted} />
    """
  end

  defp landing_page(assigns) do
    ~H"""
    <a href="#main" class="skip-link bg-primary text-white px-4 py-2 rounded focus:outline-none">
      Перейти к содержимому
    </a>

    <%!-- NAV --%>
    <header class="sticky top-0 z-50 bg-white/90 dark:bg-[#051025]/90 backdrop-blur border-b border-primary-200 dark:border-primary-900">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 flex items-center justify-between h-16" aria-label="Главная навигация">
        <a href="#" class="flex items-center gap-2.5 font-display font-bold text-lg text-primary dark:text-white tracking-tight">
          <img src={~p"/images/logo.svg"} alt="" class="w-8 h-8" />
          <span class="hidden sm:inline">БригСтарт</span>
        </a>

        <ul class="hidden md:flex items-center gap-6 text-base font-medium text-primary-700 dark:text-primary-300">
          <li><a href="#what-you-get" class="hover:text-primary dark:hover:text-white transition-colors">Что входит</a></li>
          <li><a href="#how-it-works" class="hover:text-primary dark:hover:text-white transition-colors">Как проходит</a></li>
          <li><a href="#examples" class="hover:text-primary dark:hover:text-white transition-colors">Примеры</a></li>
          <li><a href="#pricing" class="hover:text-primary dark:hover:text-white transition-colors">Стоимость</a></li>
          <li><a href="#faq" class="hover:text-primary dark:hover:text-white transition-colors">FAQ</a></li>
        </ul>

        <div class="flex items-center gap-3">
          <button id="theme-toggle" phx-hook="DarkMode" aria-label="Переключить тему"
            class="p-2 rounded-lg text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary">
            <svg class="icon-sun hidden w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707M17.657 17.657l-.707-.707M6.343 6.343l-.707-.707M12 8a4 4 0 100 8 4 4 0 000-8z"/>
            </svg>
            <svg class="icon-moon w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12.79A9 9 0 1111.21 3a7 7 0 109.79 9.79z"/>
            </svg>
          </button>

          <a href="#book"
            class="hidden sm:inline-flex items-center px-4 py-2 rounded-lg bg-accent-600 hover:bg-accent-700 text-white text-sm font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2">
            Получить консультацию
          </a>

          <button id="menu-toggle" phx-hook="MobileMenu" aria-label="Открыть меню" aria-expanded="false" aria-controls="mobile-menu"
            class="md:hidden p-2 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path class="menu-open" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
              <path class="menu-close hidden" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
      </nav>

      <div id="mobile-menu" class="hidden md:hidden border-t border-primary-200 dark:border-primary-900 bg-white dark:bg-[#051025] px-4 pb-4">
        <ul class="flex flex-col gap-1 pt-3 text-base font-medium">
          <li><a href="#what-you-get" class="block py-2 px-3 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">Что входит</a></li>
          <li><a href="#how-it-works" class="block py-2 px-3 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">Как проходит</a></li>
          <li><a href="#examples" class="block py-2 px-3 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">Примеры</a></li>
          <li><a href="#pricing" class="block py-2 px-3 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">Стоимость</a></li>
          <li><a href="#faq" class="block py-2 px-3 rounded-lg hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">FAQ</a></li>
          <li class="pt-2">
            <a href="#book" class="block text-center py-2 px-3 rounded-lg bg-accent-600 hover:bg-accent-700 text-white font-semibold transition-colors">Получить консультацию</a>
          </li>
        </ul>
      </div>
    </header>

    <main id="main">
      <%!-- SPRAY GUN ANIMATION (desktop only) --%>
      <div id="spray-painter" phx-hook="SprayPainter"
        class="hidden md:block fixed top-0 left-0 w-full h-full z-40 pointer-events-none"
        aria-hidden="true"
        data-frame-urls={Jason.encode!(Enum.map(1..11, fn i -> "/images/spray/#{i}.webp" end))}>
        <img
          src={~p"/images/spray/1.webp"}
          alt=""
          class="absolute w-[40vw] max-w-[500px]"
          style="top: 10%; left: 85%; transform: translate(-50%, -50%) scaleX(-1);"
        />
      </div>

      <%!-- 1. HERO --%>
      <section data-spray-section data-spray-dir="rtl" class="relative overflow-hidden bg-[#051025] text-white hero-stripes grain">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="absolute inset-0 opacity-20" aria-hidden="true">
          <div class="absolute top-0 right-0 w-[600px] h-[600px] bg-primary-600 rounded-full blur-[120px] translate-x-1/3 -translate-y-1/3"></div>
          <div class="absolute bottom-0 left-0 w-96 h-96 bg-accent-600 rounded-full blur-[100px] -translate-x-1/3 translate-y-1/3"></div>
        </div>
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 py-20 lg:py-32">
          <div class="max-w-3xl">
            <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-primary-800/60 border border-primary-700 text-primary-200 text-sm font-medium mb-6">
              <span class="w-2 h-2 rounded-full bg-accent animate-pulse" aria-hidden="true"></span>
              Запуск за 7–14 дней
            </div>
            <h1 class="font-display text-5xl sm:text-6xl lg:text-7xl font-extrabold leading-[1.1] mb-6 tracking-tight">
              Запуск покрасочной<br />бригады <span class="text-accent-300">под ключ</span>
            </h1>
            <p class="text-xl text-primary-200 mb-8 max-w-2xl leading-relaxed">
              Обучаем технологии, подбираем оборудование и помогаем начать зарабатывать на покраске фасадов и помещений.
            </p>
            <ul class="flex flex-col sm:flex-row gap-3 sm:gap-6 text-primary-300 text-base mb-10">
              <li class="flex items-center gap-2">
                <svg class="w-5 h-5 text-accent shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                Запуск за 7–14 дней
              </li>
              <li class="flex items-center gap-2">
                <svg class="w-5 h-5 text-accent shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                Обучение на реальных объектах
              </li>
              <li class="flex items-center gap-2">
                <svg class="w-5 h-5 text-accent shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                Комплект профоборудования
              </li>
            </ul>
            <div class="flex flex-col sm:flex-row gap-4">
              <a href="#book"
                class="inline-flex items-center justify-center px-8 py-4 rounded-xl bg-accent-600 hover:bg-accent-700 text-white text-lg font-bold transition-colors shadow-lg shadow-accent/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-[#051025]">
                Получить консультацию
                <svg class="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                </svg>
              </a>
              <a href="#earnings"
                class="inline-flex items-center justify-center px-8 py-4 rounded-xl border border-primary-700 hover:border-primary-400 text-primary-300 hover:text-white text-lg font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white">
                Рассчитать запуск
              </a>
            </div>
          </div>
        </div>
      </section>

      <%!-- 2. ДЛЯ КОГО --%>
      <section id="audience" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28 border-b border-primary-200 dark:border-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Для кого это</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Этот запуск подходит если вы:</p>
          </div>
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <.audience_card icon="building" title="Строительная бригада" desc="Хотите расширить услуги и добавить покраску в перечень работ" />
            <.audience_card icon="briefcase" title="Предприниматель" desc="Ищете новый строительный бизнес с быстрым стартом" />
            <.audience_card icon="brush" title="Маляр с опытом" desc="Хотите работать быстрее и дороже с профессиональным оборудованием" />
            <.audience_card icon="clipboard" title="Подрядчик" desc="Хотите повысить производительность и объёмы работ" />
          </div>
        </div>
      </section>

      <%!-- 3. ЗАРАБОТОК --%>
      <section id="earnings" data-spray-section data-spray-dir="rtl" class="py-20 lg:py-28 bg-primary-50 dark:bg-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Сколько можно зарабатывать</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Экономика покрасочной бригады — примерная модель на реальных объектах.</p>
          </div>
          <div class="grid lg:grid-cols-2 gap-8">
            <div class="bg-white dark:bg-[#051025] rounded-2xl p-8 border border-primary-200 dark:border-primary-800">
              <h3 class="font-display text-lg font-bold mb-6 text-primary-900 dark:text-white">Экономика бригады</h3>
              <dl class="space-y-4">
                <div class="flex justify-between items-center py-3 border-b border-primary-200 dark:border-primary-800">
                  <dt class="text-primary-600 dark:text-primary-300 text-base">Средняя площадь объекта</dt>
                  <dd class="font-bold text-primary-900 dark:text-white">300–1 000 м²</dd>
                </div>
                <div class="flex justify-between items-center py-3 border-b border-primary-200 dark:border-primary-800">
                  <dt class="text-primary-600 dark:text-primary-300 text-base">Средняя цена работ</dt>
                  <dd class="font-bold text-primary-900 dark:text-white">от X ₽ / м²</dd>
                </div>
                <div class="flex justify-between items-center py-3">
                  <dt class="text-primary-600 dark:text-primary-300 text-base">Доход бригады с объекта</dt>
                  <dd class="font-bold text-accent-600 text-lg">от X ₽</dd>
                </div>
              </dl>
            </div>
            <div class="bg-[#051025] dark:bg-primary-800/30 text-white rounded-2xl p-8 border border-primary-800 dark:border-primary-700 relative overflow-hidden grain">
              <div class="absolute top-0 right-0 w-40 h-40 bg-primary-600/20 rounded-full blur-3xl" aria-hidden="true"></div>
              <div class="relative">
                <div class="inline-flex items-center px-3 py-1 rounded-full bg-accent-600/20 border border-accent-600/30 text-accent-300 text-xs font-semibold mb-4">Пример объекта</div>
                <h3 class="font-display text-lg font-bold mb-6">Склад / Фасад / Помещение</h3>
                <dl class="space-y-4">
                  <div class="flex justify-between items-center py-3 border-b border-primary-700">
                    <dt class="text-primary-300 text-base">Площадь</dt><dd class="font-bold">XXX м²</dd>
                  </div>
                  <div class="flex justify-between items-center py-3 border-b border-primary-700">
                    <dt class="text-primary-300 text-base">Время выполнения</dt><dd class="font-bold">X дней</dd>
                  </div>
                  <div class="flex justify-between items-center py-3">
                    <dt class="text-primary-300 text-base">Доход с объекта</dt><dd class="font-bold text-accent-300 text-lg">XXX ₽</dd>
                  </div>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- 4. ЧТО ВХОДИТ --%>
      <section id="what-you-get" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Что входит в запуск</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Четыре составляющие для полного старта бригады.</p>
          </div>
          <div class="grid sm:grid-cols-2 gap-6">
            <.pillar_card num="1" icon="academic-cap" title="Обучение технологии" items={["Подготовка поверхности", "Работа с оборудованием", "Контроль качества"]} />
            <.pillar_card num="2" icon="wrench-screwdriver" title="Комплект оборудования" items={["Покрасочный аппарат", "Сопла и шланги", "Расходные материалы"]} />
            <.pillar_card num="3" icon="spray-gun" title="Практика" items={["Работа на реальном объекте", "Настройка оборудования"]} />
            <.pillar_card num="4" icon="lifebuoy" title="Поддержка после обучения" items={["Консультации", "Помощь с объектами", "Рекомендации по материалам"]} />
          </div>
        </div>
      </section>

      <%!-- 5. КАК ПРОХОДИТ --%>
      <section id="how-it-works" data-spray-section data-spray-dir="rtl" class="py-20 lg:py-28 bg-primary-50 dark:bg-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-5xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Как проходит запуск</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Четыре этапа от первого звонка до работающей бригады.</p>
          </div>
          <div class="relative">
            <div class="absolute left-6 sm:left-8 top-0 bottom-0 w-px bg-primary-200 dark:bg-primary-700" aria-hidden="true"></div>
            <div class="space-y-8">
              <.timeline_step num="1" color="bg-primary" title="Консультация и определение задач" desc="Разбираем ваши цели, подбираем оптимальный пакет и формат обучения." />
              <.timeline_step num="2" color="bg-primary" title="Подбор оборудования для бригады" desc="Комплектуем аппарат, сопла, шланги и расходники под ваши задачи." />
              <.timeline_step num="3" color="bg-primary" title="Обучение и практическая работа" desc="Технология, работа с оборудованием и практика на реальном объекте." />
              <.timeline_step num="4" color="bg-accent-600" title="Запуск бригады и сопровождение" desc="Выходите на объекты и получаете поддержку на всех этапах работы." />
            </div>
          </div>
        </div>
      </section>

      <%!-- 6. ПРИМЕРЫ РАБОТ --%>
      <section id="examples" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Примеры работ</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Реальные объекты, выполненные с использованием безвоздушного распыления.</p>
          </div>
          <div class="grid md:grid-cols-3 gap-6">
            <.example_card title="Покраска фасада" area="XXX м²" time="X дней" tech="Безвоздушное распыление" />
            <.example_card title="Покраска складского помещения" area="XXX м²" time="X дней" />
            <.example_card title="Покраска интерьера" area="XXX м²" time="X дней" />
          </div>
        </div>
      </section>

      <%!-- 7. ОБОРУДОВАНИЕ --%>
      <section id="equipment" data-spray-section data-spray-dir="rtl" class="py-20 lg:py-28 bg-primary-50 dark:bg-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-5xl mx-auto px-4 sm:px-6">
          <div class="grid lg:grid-cols-2 gap-10 items-center">
            <div>
              <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Стартовый комплект бригады</h2>
              <p class="text-primary-500 dark:text-primary-300 text-base mb-8 leading-relaxed">Этот комплект позволяет сразу начать работу на объектах.</p>
              <ul class="space-y-3">
                <.equipment_item text="Аппарат безвоздушного распыления" />
                <.equipment_item text="Комплект сопел" />
                <.equipment_item text="Фильтры" />
                <.equipment_item text="Шланги" />
                <.equipment_item text="Базовые расходные материалы" />
              </ul>
            </div>
            <div class="aspect-square bg-white dark:bg-[#051025] rounded-2xl border border-primary-200 dark:border-primary-800 flex items-center justify-center">
              <svg class="w-24 h-24 text-primary-200 dark:text-primary-700" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
            </div>
          </div>
        </div>
      </section>

      <%!-- 8. СКОРОСТЬ --%>
      <section id="speed" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28" phx-hook="SpeedBar">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-4xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Почему это быстрее</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Безвоздушное распыление увеличивает скорость работы в несколько раз.</p>
          </div>
          <div class="space-y-6">
            <div>
              <div class="flex justify-between mb-2">
                <span class="text-base font-medium text-primary-700 dark:text-primary-300">Кисть</span>
                <span class="text-base font-bold text-primary-900 dark:text-white">~50 м² / день</span>
              </div>
              <div class="h-4 bg-primary-100 dark:bg-primary-800 rounded-full overflow-hidden">
                <div class="h-full bg-primary-300 dark:bg-primary-600 rounded-full speed-bar" style="width: 6.25%"></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between mb-2">
                <span class="text-base font-medium text-primary-700 dark:text-primary-300">Валик</span>
                <span class="text-base font-bold text-primary-900 dark:text-white">~100 м² / день</span>
              </div>
              <div class="h-4 bg-primary-100 dark:bg-primary-800 rounded-full overflow-hidden">
                <div class="h-full bg-primary-400 dark:bg-primary-500 rounded-full speed-bar" style="width: 12.5%; animation-delay: 0.2s"></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between mb-2">
                <span class="text-base font-medium text-primary-900 dark:text-white font-bold">Безвоздушное распыление</span>
                <span class="text-base font-bold text-accent-600">400–800 м² / день</span>
              </div>
              <div class="h-5 bg-primary-100 dark:bg-primary-800 rounded-full overflow-hidden">
                <div class="h-full bg-gradient-to-r from-primary to-accent-600 rounded-full speed-bar" style="width: 100%; animation-delay: 0.4s"></div>
              </div>
            </div>
          </div>
          <div class="mt-8 p-4 rounded-xl bg-accent-50 dark:bg-accent-950/30 border border-accent-200 dark:border-accent-900/50 text-center">
            <p class="text-base text-accent-800 dark:text-accent-300 font-medium">
              До <span class="font-extrabold text-accent-600">16x</span> быстрее по сравнению с ручной покраской
            </p>
          </div>
        </div>
      </section>

      <%!-- 9. ОТЗЫВЫ --%>
      <section id="testimonials" data-spray-section data-spray-dir="rtl" class="py-20 lg:py-28 bg-primary-50 dark:bg-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-5xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Отзывы и кейсы</h2>
          </div>
          <div class="bg-white dark:bg-[#051025] rounded-2xl p-8 sm:p-10 border border-primary-200 dark:border-primary-800 relative overflow-hidden">
            <div class="absolute top-6 right-8 text-primary-100 dark:text-primary-800" aria-hidden="true">
              <svg class="w-20 h-20" fill="currentColor" viewBox="0 0 24 24"><path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z"/></svg>
            </div>
            <div class="relative">
              <blockquote class="text-primary-700 dark:text-primary-200 text-lg leading-relaxed mb-6">
                Бригада из 3 человек прошла обучение и начала выполнять объекты по покраске фасадов. За первый месяц выполнено 3 объекта.
              </blockquote>
              <div class="flex flex-wrap gap-3">
                <span class="inline-flex items-center px-3 py-1.5 rounded-lg bg-primary-100 dark:bg-primary-800 text-primary-700 dark:text-primary-300 text-sm font-medium">Быстрый запуск</span>
                <span class="inline-flex items-center px-3 py-1.5 rounded-lg bg-primary-100 dark:bg-primary-800 text-primary-700 dark:text-primary-300 text-sm font-medium">Высокая производительность</span>
                <span class="inline-flex items-center px-3 py-1.5 rounded-lg bg-accent-100 dark:bg-accent-900/30 text-accent-700 dark:text-accent-300 text-sm font-medium">Рост дохода бригады</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- 10. СТОИМОСТЬ --%>
      <section id="pricing" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Пакеты запуска</h2>
            <p class="text-primary-500 dark:text-primary-300 text-xl max-w-2xl mx-auto">Стоимость зависит от комплектации и задач.</p>
          </div>
          <div class="grid md:grid-cols-3 gap-6">
            <%!-- Старт --%>
            <div class="bg-white dark:bg-primary-900 rounded-2xl border border-primary-200 dark:border-primary-800 p-8 flex flex-col">
              <h3 class="font-display text-xl font-bold text-primary-900 dark:text-white mb-2">Старт</h3>
              <p class="text-primary-500 dark:text-primary-400 text-base mb-6 leading-relaxed">Обучение технологии и начальная консультация.</p>
              <ul class="space-y-3 text-base text-primary-600 dark:text-primary-300 mb-8 flex-1">
                <.check_item>Обучение технологии</.check_item>
                <.check_item>Консультация</.check_item>
              </ul>
              <a href="#book" class="inline-flex items-center justify-center py-3 px-6 rounded-xl border-2 border-primary hover:bg-primary hover:text-white text-primary font-bold text-base transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2">
                Узнать стоимость
              </a>
            </div>
            <%!-- Профессиональный --%>
            <div class="relative bg-white dark:bg-primary-900 rounded-2xl border-2 border-primary shadow-xl pricing-glow p-8 flex flex-col">
              <div class="absolute -top-3.5 left-1/2 -translate-x-1/2">
                <span class="inline-flex items-center px-4 py-1 rounded-full bg-accent-600 text-white text-xs font-bold shadow-lg">Популярный</span>
              </div>
              <h3 class="font-display text-xl font-bold text-primary-900 dark:text-white mb-2">Профессиональный</h3>
              <p class="text-primary-500 dark:text-primary-400 text-base mb-6 leading-relaxed">Обучение + полный комплект оборудования.</p>
              <ul class="space-y-3 text-base text-primary-600 dark:text-primary-300 mb-8 flex-1">
                <.check_item>Обучение технологии</.check_item>
                <.check_item>Комплект оборудования</.check_item>
                <.check_item>Практика на объекте</.check_item>
              </ul>
              <a href="#book" class="inline-flex items-center justify-center py-3 px-6 rounded-xl bg-accent-600 hover:bg-accent-700 text-white font-bold text-base transition-colors shadow-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2">
                Узнать стоимость
              </a>
            </div>
            <%!-- Под ключ --%>
            <div class="bg-[#051025] dark:bg-primary-800/40 text-white rounded-2xl border border-primary-800 dark:border-primary-700 p-8 flex flex-col relative overflow-hidden grain">
              <div class="absolute top-0 right-0 w-32 h-32 bg-primary-600/10 rounded-full blur-2xl" aria-hidden="true"></div>
              <div class="relative flex flex-col flex-1">
                <h3 class="font-display text-xl font-bold mb-2">Под ключ</h3>
                <p class="text-primary-400 text-base mb-6 leading-relaxed">Полный запуск: обучение, оборудование и сопровождение.</p>
                <ul class="space-y-3 text-base text-primary-300 mb-8 flex-1">
                  <.check_item color="text-accent-400">Обучение технологии</.check_item>
                  <.check_item color="text-accent-400">Комплект оборудования</.check_item>
                  <.check_item color="text-accent-400">Практика на объекте</.check_item>
                  <.check_item color="text-accent-400">Сопровождение и поддержка</.check_item>
                </ul>
                <a href="#book" class="inline-flex items-center justify-center py-3 px-6 rounded-xl bg-white text-primary-900 hover:bg-primary-100 font-bold text-base transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-[#051025]">
                  Узнать стоимость
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- 11. FAQ --%>
      <section id="faq" data-spray-section data-spray-dir="rtl" class="py-20 lg:py-28 bg-primary-50 dark:bg-primary-900">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="max-w-4xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-14">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 text-primary-900 dark:text-white tracking-tight">Частые вопросы</h2>
          </div>
          <div class="space-y-3">
            <.faq_item question="Сколько человек нужно для бригады?" answer="Обычно 2–4 человека. Мы поможем определить оптимальный состав под ваши задачи." />
            <.faq_item question="Сколько длится обучение?" answer="От нескольких дней до двух недель — зависит от выбранного пакета и вашего начального уровня." />
            <.faq_item question="Какие материалы используются?" answer="Подбираются под тип объекта и задачи. На обучении разбираем все основные типы покрытий." />
            <.faq_item question="Можно ли начать без опыта?" answer="Да. Обучение включает все базовые навыки работы с оборудованием и технологией." />
          </div>
        </div>
      </section>

      <%!-- 12. ФИНАЛЬНЫЙ CTA --%>
      <section id="book" data-spray-section data-spray-dir="ltr" class="py-20 lg:py-28 bg-[#051025] text-white relative overflow-hidden grain">
        <div class="spray-overlay" aria-hidden="true"></div>
        <div class="absolute inset-0 opacity-10" aria-hidden="true">
          <div class="absolute top-1/2 left-1/2 w-[800px] h-[800px] bg-primary-600 rounded-full blur-[200px] -translate-x-1/2 -translate-y-1/2"></div>
        </div>
        <div class="relative max-w-4xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-10">
            <h2 class="font-display text-4xl sm:text-5xl font-extrabold mb-4 tracking-tight">Получите план запуска</h2>
            <p class="text-primary-300 text-lg leading-relaxed max-w-xl mx-auto">
              Получите план запуска покрасочной бригады и список необходимого оборудования.
            </p>
          </div>

          <%= if @submitted do %>
            <div class="bg-primary-900/80 backdrop-blur border border-primary-800 rounded-2xl p-8 text-center">
              <div class="w-16 h-16 rounded-full bg-green-500/20 flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
              </div>
              <h3 class="font-display text-xl font-bold mb-2">Заявка отправлена!</h3>
              <p class="text-primary-300">Свяжемся с вами в течение 24 часов.</p>
            </div>
          <% else %>
            <.form for={@form} phx-change="validate" phx-submit="submit"
              class="bg-primary-900/80 backdrop-blur border border-primary-800 rounded-2xl p-6 sm:p-8"
              aria-label="Форма заявки">
              <div class="grid sm:grid-cols-2 gap-4 mb-4">
                <div>
                  <label for="submission_name" class="block text-base font-medium text-primary-200 mb-1">Имя</label>
                  <.input field={@form[:name]} type="text" placeholder="Ваше имя" autocomplete="given-name"
                    class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-base" />
                </div>
                <div>
                  <label for="submission_phone" class="block text-base font-medium text-primary-200 mb-1">Телефон</label>
                  <.input field={@form[:phone]} type="tel" placeholder="+7 XXX XXX XXXX" autocomplete="tel"
                    class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-base" />
                </div>
              </div>
              <div class="mb-6">
                <label for="submission_email" class="block text-base font-medium text-primary-200 mb-1">Email</label>
                <.input field={@form[:email]} type="email" placeholder="you@example.com" autocomplete="email"
                  class="w-full px-4 py-3 rounded-xl bg-primary-800 border border-primary-700 text-white placeholder-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-400 focus:border-transparent text-base" />
              </div>
              <button type="submit" phx-disable-with="Отправка..."
                class="w-full py-4 rounded-xl bg-accent-600 hover:bg-accent-700 text-white font-bold text-lg transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-[#051025]">
                Получить консультацию
              </button>
              <p class="text-center text-xs text-primary-500 mt-3">Свяжемся в течение 24 часов. Без обязательств.</p>
            </.form>
          <% end %>

          <div class="mt-6 flex items-center justify-center gap-3 text-primary-400 text-base">
            <svg class="w-4 h-4 text-primary-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
            </svg>
            Или позвоните: <a href="tel:+79006546821" class="text-primary-300 hover:text-white transition-colors font-medium">+7 900 654-68-21</a>
          </div>
        </div>
      </section>
    </main>

    <%!-- FOOTER --%>
    <footer class="border-t border-primary-200 dark:border-primary-900 bg-white dark:bg-[#051025] py-10">
      <div class="max-w-7xl mx-auto px-4 sm:px-6">
        <div class="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div class="flex items-center gap-2.5 font-display font-bold text-primary dark:text-white">
            <img src={~p"/images/logo.svg"} alt="" class="w-7 h-7" aria-hidden="true" />
            БригСтарт
          </div>
          <nav aria-label="Навигация подвала">
            <ul class="flex flex-wrap justify-center gap-4 sm:gap-6 text-base text-primary-500 dark:text-primary-400">
              <li><a href="#" class="hover:text-primary dark:hover:text-white transition-colors">Политика конфиденциальности</a></li>
              <li><a href="tel:+79006546821" class="hover:text-primary dark:hover:text-white transition-colors">+7 900 654-68-21</a></li>
            </ul>
          </nav>
          <p class="text-base text-primary-400 dark:text-primary-500">
            &copy; <%= Date.utc_today().year %> БригСтарт
          </p>
        </div>
      </div>
    </footer>
    """
  end

  # Component helpers

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :desc, :string, required: true

  defp audience_card(assigns) do
    ~H"""
    <div class="group relative p-6 rounded-2xl border border-primary-200 dark:border-primary-800 hover:border-primary/40 transition-all bg-white dark:bg-primary-900 overflow-hidden">
      <div class="absolute top-0 right-0 w-24 h-24 bg-primary-50 dark:bg-primary-800/50 rounded-full -translate-y-1/2 translate-x-1/2 group-hover:scale-110 transition-transform" aria-hidden="true"></div>
      <div class="relative">
        <div class="w-12 h-12 rounded-xl bg-primary-100 dark:bg-primary-800 flex items-center justify-center mb-4" aria-hidden="true">
          <.audience_icon name={@icon} />
        </div>
        <h3 class="text-base font-bold mb-2 text-primary-900 dark:text-white"><%= @title %></h3>
        <p class="text-primary-500 dark:text-primary-400 text-base leading-relaxed"><%= @desc %></p>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  defp audience_icon(%{name: "building"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M18 18.72a9.094 9.094 0 0 0 3.741-.479 3 3 0 0 0-4.682-2.72m.94 3.198.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0 1 12 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 0 1 6 18.719m12 0a5.971 5.971 0 0 0-.941-3.197m0 0A5.995 5.995 0 0 0 12 12.75a5.995 5.995 0 0 0-5.058 2.772m0 0a3 3 0 0 0-4.681 2.72 8.986 8.986 0 0 0 3.74.477m.94-3.197a5.971 5.971 0 0 0-.94 3.197M15 6.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm6 3a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Zm-13.5 0a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Z"/></svg>
    """
  end
  defp audience_icon(%{name: "briefcase"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15.59 14.37a6 6 0 0 1-5.84 7.38v-4.8m5.84-2.58a14.98 14.98 0 0 0 6.16-12.12A14.98 14.98 0 0 0 9.631 8.41m5.96 5.96a14.926 14.926 0 0 1-5.841 2.58m-.119-8.54a6 6 0 0 0-7.381 5.84h4.8m2.581-5.84a14.927 14.927 0 0 0-2.58 5.84m2.699 2.7c-.103.021-.207.041-.311.06a15.09 15.09 0 0 1-2.448-2.448 14.9 14.9 0 0 1 .06-.312m-2.24 2.39a4.493 4.493 0 0 0-1.757 4.306 4.493 4.493 0 0 0 4.306-1.758M16.5 9a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z"/></svg>
    """
  end
  defp audience_icon(%{name: "brush"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9.53 16.122a3 3 0 0 0-5.78 1.128 2.25 2.25 0 0 1-2.4 2.245 4.5 4.5 0 0 0 8.4-2.245c0-.399-.078-.78-.22-1.128Zm0 0a15.998 15.998 0 0 0 3.388-1.62m-5.043-.025a15.994 15.994 0 0 1 1.622-3.395m3.42 3.42a15.995 15.995 0 0 0 4.764-4.648l3.876-5.814a1.151 1.151 0 0 0-1.597-1.597L14.146 6.32a15.996 15.996 0 0 0-4.649 4.763m3.42 3.42a6.776 6.776 0 0 0-3.42-3.42"/></svg>
    """
  end
  defp audience_icon(%{name: "clipboard"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z"/></svg>
    """
  end
  defp audience_icon(assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
    """
  end

  attr :num, :string, required: true
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :items, :list, required: true

  defp pillar_card(assigns) do
    ~H"""
    <div class="p-8 rounded-2xl border border-primary-200 dark:border-primary-800 hover:shadow-lg hover:shadow-primary/5 transition-all bg-white dark:bg-primary-900">
      <div class="flex items-start gap-4">
        <div class="w-12 h-12 rounded-xl bg-primary-100 dark:bg-primary-800 flex items-center justify-center shrink-0" aria-hidden="true">
          <.pillar_icon name={@icon} />
        </div>
        <div>
          <h3 class="text-lg font-bold mb-3 text-primary-900 dark:text-white"><%= @title %></h3>
          <ul class="space-y-2 text-primary-500 dark:text-primary-300 text-base">
            <%= for item <- @items do %>
              <li class="flex items-start gap-2">
                <svg class="w-4 h-4 text-primary shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                <%= item %>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  defp pillar_icon(%{name: "academic-cap"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4.26 10.147a60.438 60.438 0 0 0-.491 6.347A48.62 48.62 0 0 1 12 20.904a48.62 48.62 0 0 1 8.232-4.41 60.46 60.46 0 0 0-.491-6.347m-15.482 0a50.636 50.636 0 0 0-2.658-.813A59.906 59.906 0 0 1 12 3.493a59.903 59.903 0 0 1 10.399 5.84c-.896.248-1.783.52-2.658.814m-15.482 0A50.717 50.717 0 0 1 12 13.489a50.702 50.702 0 0 1 7.74-3.342M6.75 15a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Zm0 0v-3.675A55.378 55.378 0 0 1 12 8.443m-7.007 11.55A5.981 5.981 0 0 0 6.75 15.75v-1.5"/></svg>
    """
  end
  defp pillar_icon(%{name: "wrench-screwdriver"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11.42 15.17 17.25 21A2.652 2.652 0 0 0 21 17.25l-5.877-5.877M11.42 15.17l2.496-3.03c.317-.384.74-.626 1.208-.766M11.42 15.17l-4.655 5.653a2.548 2.548 0 1 1-3.586-3.586l6.837-5.63m5.108-.233c.55-.164 1.163-.188 1.743-.14a4.5 4.5 0 0 0 4.486-6.336l-3.276 3.277a3.004 3.004 0 0 1-2.25-2.25l3.276-3.276a4.5 4.5 0 0 0-6.336 4.486c.091 1.076-.071 2.264-.904 2.95l-.102.085m-1.745 1.437L5.909 7.5H4.5L2.25 3.75l1.5-1.5L7.5 4.5v1.409l4.26 4.26m-1.745 1.437 1.745-1.437m6.615 8.206L15.75 15.75M4.867 19.125h.008v.008h-.008v-.008Z"/></svg>
    """
  end
  defp pillar_icon(%{name: "spray-gun"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
      <%!-- gun body --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M13 6h3.5a1 1 0 0 1 1 1v1.5a1 1 0 0 1-1 1H13m0-3.5V4.5a1.5 1.5 0 0 1 1.5-1.5h0a1.5 1.5 0 0 1 1.5 1.5V6m-3 0v3.5"/>
      <%!-- barrel + nozzle --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M8 8.5h5v2H8l-.5-.5v-1zM6 9.5H8"/>
      <%!-- trigger --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M14 9.5v2.5a1 1 0 0 1-1 1h-1"/>
      <%!-- handle --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M13 12l1.5 7.5a1.5 1.5 0 0 1-1.5 1.5h-1a1.5 1.5 0 0 1-1.5-1.5L12 12"/>
      <%!-- spray lines --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M2 9.5h3M2.5 7l2.5 1.5M2.5 12l2.5-1.5"/>
      <%!-- hook --%>
      <path stroke-linecap="round" stroke-linejoin="round" d="M16 3a2 2 0 0 1 2 2v0a2 2 0 0 1-2 2"/>
    </svg>
    """
  end
  defp pillar_icon(%{name: "lifebuoy"} = assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16.712 4.33a9.027 9.027 0 0 1 1.652 1.306c.51.51.944 1.064 1.306 1.652M16.712 4.33l-3.448 4.138m3.448-4.138a9.014 9.014 0 0 0-9.424 0M19.67 7.288l-4.138 3.448m4.138-3.448a9.014 9.014 0 0 1 0 9.424m-4.138-5.976a3.736 3.736 0 0 0-.88-1.388 3.737 3.737 0 0 0-1.388-.88m2.268 2.268a3.765 3.765 0 0 1 0 2.528m-2.268-4.796a3.765 3.765 0 0 0-2.528 0m4.796 4.796c-.181.506-.475.982-.88 1.388a3.736 3.736 0 0 1-1.388.88m2.268-2.268 4.138 3.448m0 0a9.027 9.027 0 0 1-1.306 1.652c-.51.51-1.064.944-1.652 1.306m0 0-3.448-4.138m3.448 4.138a9.014 9.014 0 0 1-9.424 0m5.976-4.138a3.765 3.765 0 0 1-2.528 0m0 0a3.736 3.736 0 0 1-1.388-.88 3.737 3.737 0 0 1-.88-1.388m2.268 2.268L7.288 19.67m0 0a9.024 9.024 0 0 1-1.652-1.306 9.027 9.027 0 0 1-1.306-1.652m0 0 4.138-3.448M4.33 16.712a9.014 9.014 0 0 1 0-9.424m4.138 5.976a3.765 3.765 0 0 1 0-2.528m0 0c.181-.506.475-.982.88-1.388a3.736 3.736 0 0 1 1.388-.88m-2.268 2.268L4.33 7.288m6.406 1.18L7.288 4.33m0 0a9.024 9.024 0 0 0-1.652 1.306A9.025 9.025 0 0 0 4.33 7.288"/></svg>
    """
  end
  defp pillar_icon(assigns) do
    ~H"""
    <svg class="w-8 h-8 text-primary dark:text-primary-200" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
    """
  end

  attr :num, :string, required: true
  attr :color, :string, required: true
  attr :title, :string, required: true
  attr :desc, :string, required: true

  defp timeline_step(assigns) do
    ~H"""
    <div class="relative flex gap-6 sm:gap-8">
      <div class={"relative z-10 w-12 h-12 sm:w-16 sm:h-16 rounded-full #{@color} text-white flex items-center justify-center font-display font-extrabold text-lg sm:text-xl shrink-0 shadow-lg shadow-primary/20"}>
        <%= @num %>
      </div>
      <div class="pt-2 sm:pt-3 pb-4">
        <h3 class="font-bold text-lg text-primary-900 dark:text-white mb-1"><%= @title %></h3>
        <p class="text-primary-500 dark:text-primary-400 text-base leading-relaxed"><%= @desc %></p>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :area, :string, required: true
  attr :time, :string, required: true
  attr :tech, :string, default: nil

  defp example_card(assigns) do
    ~H"""
    <div class="group bg-white dark:bg-primary-900 rounded-2xl border border-primary-200 dark:border-primary-800 overflow-hidden hover:shadow-lg transition-shadow">
      <div class="aspect-[4/3] bg-primary-100 dark:bg-primary-800 flex items-center justify-center">
        <svg class="w-16 h-16 text-primary-300 dark:text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
      </div>
      <div class="p-6">
        <h3 class="font-bold text-base text-primary-900 dark:text-white mb-3"><%= @title %></h3>
        <dl class="space-y-2 text-base">
          <div class="flex justify-between"><dt class="text-primary-500 dark:text-primary-400">Площадь</dt><dd class="font-semibold text-primary-900 dark:text-white"><%= @area %></dd></div>
          <div class="flex justify-between"><dt class="text-primary-500 dark:text-primary-400">Время</dt><dd class="font-semibold text-primary-900 dark:text-white"><%= @time %></dd></div>
          <%= if @tech do %>
            <div class="flex justify-between"><dt class="text-primary-500 dark:text-primary-400">Технология</dt><dd class="font-semibold text-primary-900 dark:text-white"><%= @tech %></dd></div>
          <% end %>
        </dl>
      </div>
    </div>
    """
  end

  attr :text, :string, required: true
  defp equipment_item(assigns) do
    ~H"""
    <li class="flex items-start gap-3 text-primary-700 dark:text-primary-200">
      <div class="w-6 h-6 rounded-md bg-primary/10 dark:bg-primary-800 flex items-center justify-center shrink-0 mt-0.5" aria-hidden="true">
        <svg class="w-4 h-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
      </div>
      <span class="text-base"><%= @text %></span>
    </li>
    """
  end

  attr :color, :string, default: "text-primary"
  slot :inner_block, required: true
  defp check_item(assigns) do
    ~H"""
    <li class="flex items-start gap-2">
      <svg class={"w-5 h-5 #{@color} shrink-0 mt-0.5"} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr :question, :string, required: true
  attr :answer, :string, required: true

  defp faq_item(assigns) do
    ~H"""
    <details class="group border border-primary-200 dark:border-primary-800 rounded-xl overflow-hidden bg-white dark:bg-[#051025]">
      <summary class="flex items-center justify-between gap-4 px-6 py-4 cursor-pointer select-none hover:bg-primary-50 dark:hover:bg-primary-900 transition-colors">
        <span class="font-semibold text-base sm:text-lg text-primary-900 dark:text-white"><%= @question %></span>
        <span class="faq-icon shrink-0 text-primary text-xl leading-none" aria-hidden="true">+</span>
      </summary>
      <div class="px-6 pb-5 text-primary-600 dark:text-primary-300 text-base leading-relaxed">
        <%= @answer %>
      </div>
    </details>
    """
  end
end
