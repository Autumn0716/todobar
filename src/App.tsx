import { type CSSProperties, FormEvent, useEffect, useMemo, useState } from "react";
import {
  Archive,
  CalendarDays,
  Check,
  Clock3,
  Inbox,
  ListChecks,
  Minus,
  PanelLeftOpen,
  Plus,
  RotateCcw,
  Settings,
  Trash2,
  X,
} from "lucide-react";
import {
  addCustomList,
  addTask,
  createInitialBoard,
  defaultSettings,
  deleteTask,
  replaceSettings,
  type Section,
  type SectionIcon,
  type Task,
  type TodobarBoard,
  type TodobarSettings,
  toggleSection,
  toggleTask,
  updateSettings,
} from "./state";

const STORAGE_KEY = "todobar:v2";

type CssVars = CSSProperties & Record<`--${string}`, string>;

type SliderConfig = {
  key: keyof TodobarSettings;
  label: string;
  min: number;
  max: number;
  step: number;
  unit: string;
};

const windowSliders: SliderConfig[] = [
  { key: "panelWidth", label: "面板宽度", min: 300, max: 460, step: 1, unit: "px" },
  { key: "visibleTab", label: "可见标签", min: 18, max: 76, step: 1, unit: "px" },
];

const handleSliders: SliderConfig[] = [
  { key: "buttonHeight", label: "按钮高度", min: 52, max: 128, step: 1, unit: "px" },
  { key: "verticalPosition", label: "垂直位置", min: 8, max: 68, step: 1, unit: "%" },
];

const taskSliders: SliderConfig[] = [
  { key: "rowHeight", label: "行高", min: 38, max: 62, step: 1, unit: "px" },
  { key: "rowGap", label: "行距", min: 4, max: 16, step: 1, unit: "px" },
  { key: "textSize", label: "文字大小", min: 11, max: 15, step: 0.5, unit: "px" },
];

const feelSliders: SliderConfig[] = [
  { key: "motionMs", label: "动效", min: 80, max: 520, step: 10, unit: "ms" },
  { key: "cornerRadius", label: "圆角", min: 10, max: 30, step: 1, unit: "px" },
  { key: "surfaceOpacity", label: "表面", min: 78, max: 100, step: 1, unit: "%" },
];

export default function App() {
  const [board, setBoard] = useLocalStorageState(STORAGE_KEY, createInitialBoard);
  const settings = board.settings;
  const customSections = board.customListIds
    .map((id) => board.sections[id])
    .filter(Boolean);

  const shellStyle = useMemo<CssVars>(
    () => ({
      "--panel-width": `${settings.panelWidth}px`,
      "--visible-tab": `${settings.visibleTab}px`,
      "--button-height": `${settings.buttonHeight}px`,
      "--vertical-position": `${settings.verticalPosition}%`,
      "--row-height": `${settings.rowHeight}px`,
      "--row-gap": `${settings.rowGap}px`,
      "--text-size": `${settings.textSize}px`,
      "--motion": `${settings.motionMs}ms`,
      "--corner-radius": `${settings.cornerRadius}px`,
      "--surface-opacity": `${settings.surfaceOpacity / 100}`,
    }),
    [settings],
  );

  const updateBoard = (updater: (current: TodobarBoard) => TodobarBoard) => {
    setBoard((current) => updater(current));
  };

  return (
    <main className={`workspace theme-${settings.theme}`} style={shellStyle}>
      <Backdrop />
      <section className={`todobar ${board.panelOpen ? "is-open" : ""}`} aria-label="Todobar">
        <button
          className="edge-handle"
          type="button"
          aria-label={board.panelOpen ? "收起 TodoBar" : "展开 TodoBar"}
          onClick={() => setBoard((current) => ({ ...current, panelOpen: !current.panelOpen }))}
        >
          <PanelLeftOpen aria-hidden="true" size={18} />
        </button>

        <div className="panel">
          {board.settingsOpen ? (
            <SettingsView
              settings={settings}
              onClose={() => setBoard((current) => ({ ...current, settingsOpen: false }))}
              onReset={() => updateBoard((current) => replaceSettings(current, defaultSettings))}
              onSettingsChange={(patch) => updateBoard((current) => updateSettings(current, patch))}
            />
          ) : (
            <TodoView
              sections={board.sections}
              customSections={customSections}
              onOpenSettings={() => setBoard((current) => ({ ...current, settingsOpen: true }))}
              onAddTask={(sectionId, title) => updateBoard((current) => addTask(current, sectionId, title))}
              onToggleTask={(sectionId, taskId) =>
                updateBoard((current) => toggleTask(current, sectionId, taskId))
              }
              onDeleteTask={(sectionId, taskId) =>
                updateBoard((current) => deleteTask(current, sectionId, taskId))
              }
              onToggleSection={(sectionId) =>
                updateBoard((current) => toggleSection(current, sectionId))
              }
              onAddList={(title) => updateBoard((current) => addCustomList(current, title))}
            />
          )}
        </div>
      </section>
    </main>
  );
}

function TodoView({
  sections,
  customSections,
  onOpenSettings,
  onAddTask,
  onToggleTask,
  onDeleteTask,
  onToggleSection,
  onAddList,
}: {
  sections: Record<string, Section>;
  customSections: Section[];
  onOpenSettings: () => void;
  onAddTask: (sectionId: string, title: string) => void;
  onToggleTask: (sectionId: string, taskId: string) => void;
  onDeleteTask: (sectionId: string, taskId: string) => void;
  onToggleSection: (sectionId: string) => void;
  onAddList: (title: string) => void;
}) {
  return (
    <>
      <header className="panel-header">
        <div className="brand-mark">
          <Check aria-hidden="true" size={20} />
        </div>
        <h1>TodoBar</h1>
        <button className="icon-button" type="button" aria-label="打开任务设置" onClick={onOpenSettings}>
          <Settings aria-hidden="true" size={19} />
        </button>
      </header>

      <div className="section-stack">
        <TaskSection
          section={sections.today}
          countMode="done"
          onAddTask={onAddTask}
          onToggleTask={onToggleTask}
          onDeleteTask={onDeleteTask}
          onToggleSection={onToggleSection}
        />
        <TaskSection
          section={sections.month}
          countMode="total"
          onAddTask={onAddTask}
          onToggleTask={onToggleTask}
          onDeleteTask={onDeleteTask}
          onToggleSection={onToggleSection}
        />

        <section className="task-section lists-block">
          <SectionHeading
            icon="list"
            title="清单"
            countText={`${customSections.length} 个自定义`}
            collapsed={false}
            onToggle={() => undefined}
          />
          <AddRow placeholder="新建清单..." icon="list" onSubmit={onAddList} />
          {customSections.map((section) => (
            <CustomList
              key={section.id}
              section={section}
              onAddTask={onAddTask}
              onToggleTask={onToggleTask}
              onDeleteTask={onDeleteTask}
              onToggleSection={onToggleSection}
            />
          ))}
        </section>
      </div>
    </>
  );
}

function TaskSection({
  section,
  countMode,
  onAddTask,
  onToggleTask,
  onDeleteTask,
  onToggleSection,
}: {
  section: Section;
  countMode: "done" | "total";
  onAddTask: (sectionId: string, title: string) => void;
  onToggleTask: (sectionId: string, taskId: string) => void;
  onDeleteTask: (sectionId: string, taskId: string) => void;
  onToggleSection: (sectionId: string) => void;
}) {
  const completed = section.tasks.filter((task) => task.completed).length;
  const countText =
    countMode === "done"
      ? `${completed} 已完成 · 共 ${section.tasks.length}`
      : `${section.tasks.length} 个任务`;

  return (
    <section className="task-section">
      <SectionHeading
        icon={section.icon}
        title={section.title}
        countText={countText}
        collapsed={section.collapsed}
        onToggle={() => onToggleSection(section.id)}
      />
      {!section.collapsed && (
        <div className="task-list">
          <AddRow
            placeholder={section.addPlaceholder}
            icon="inbox"
            onSubmit={(title) => onAddTask(section.id, title)}
          />
          {section.tasks.map((task) => (
            <TaskRow
              key={task.id}
              task={task}
              onToggle={() => onToggleTask(section.id, task.id)}
              onDelete={() => onDeleteTask(section.id, task.id)}
            />
          ))}
        </div>
      )}
    </section>
  );
}

function CustomList({
  section,
  onAddTask,
  onToggleTask,
  onDeleteTask,
  onToggleSection,
}: {
  section: Section;
  onAddTask: (sectionId: string, title: string) => void;
  onToggleTask: (sectionId: string, taskId: string) => void;
  onDeleteTask: (sectionId: string, taskId: string) => void;
  onToggleSection: (sectionId: string) => void;
}) {
  return (
    <div className="custom-list">
      <button className="custom-list-header" type="button" onClick={() => onToggleSection(section.id)}>
        <span>{section.title}</span>
        <strong>{section.tasks.length}</strong>
        <Minus aria-hidden="true" size={15} />
      </button>
      {!section.collapsed && (
        <div className="task-list custom-list-body">
          {section.tasks.map((task) => (
            <TaskRow
              key={task.id}
              task={task}
              onToggle={() => onToggleTask(section.id, task.id)}
              onDelete={() => onDeleteTask(section.id, task.id)}
            />
          ))}
          <AddRow
            placeholder={section.addPlaceholder}
            icon="inbox"
            onSubmit={(title) => onAddTask(section.id, title)}
          />
        </div>
      )}
    </div>
  );
}

function SectionHeading({
  icon,
  title,
  countText,
  collapsed,
  onToggle,
}: {
  icon: SectionIcon;
  title: string;
  countText: string;
  collapsed: boolean;
  onToggle: () => void;
}) {
  return (
    <div className="section-heading">
      <IconFor name={icon} size={18} />
      <h2>{title}</h2>
      <span>{countText}</span>
      <button className="collapse-button" type="button" aria-label={`${collapsed ? "展开" : "折叠"}${title}`} onClick={onToggle}>
        <Minus aria-hidden="true" size={16} />
      </button>
      {collapsed && <span className="collapsed-dot" aria-hidden="true" />}
    </div>
  );
}

function AddRow({
  placeholder,
  icon,
  onSubmit,
}: {
  placeholder: string;
  icon: SectionIcon | "inbox";
  onSubmit: (title: string) => void;
}) {
  const [value, setValue] = useState("");

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    onSubmit(value);
    setValue("");
  };

  return (
    <form className="add-row" onSubmit={handleSubmit}>
      {icon === "inbox" ? <Inbox aria-hidden="true" size={18} /> : <IconFor name={icon} size={18} />}
      <input
        aria-label={placeholder}
        placeholder={placeholder}
        value={value}
        onChange={(event) => setValue(event.currentTarget.value)}
      />
      <button type="submit" aria-label={placeholder}>
        <Plus aria-hidden="true" size={19} />
      </button>
    </form>
  );
}

function TaskRow({ task, onToggle, onDelete }: { task: Task; onToggle: () => void; onDelete: () => void }) {
  return (
    <article className={`task-row ${task.completed ? "is-complete" : ""}`}>
      <button className="check-button" type="button" aria-label={`切换${task.title}`} onClick={onToggle}>
        {task.completed && <Check aria-hidden="true" size={15} />}
      </button>
      <div className="task-copy">
        <h3>{task.title}</h3>
        <p>{task.meta}</p>
      </div>
      <span className={`priority-dot ${task.focus ? "is-focus" : ""}`} aria-hidden="true" />
      <button className="delete-button" type="button" aria-label={`删除${task.title}`} onClick={onDelete}>
        <Trash2 aria-hidden="true" size={16} />
      </button>
    </article>
  );
}

function SettingsView({
  settings,
  onClose,
  onReset,
  onSettingsChange,
}: {
  settings: TodobarSettings;
  onClose: () => void;
  onReset: () => void;
  onSettingsChange: (settings: Partial<TodobarSettings>) => void;
}) {
  return (
    <div className="settings-view">
      <header className="settings-header">
        <h1>任务设置</h1>
        <div className="settings-actions">
          <button className="icon-button framed" type="button" aria-label="重置任务设置" onClick={onReset}>
            <RotateCcw aria-hidden="true" size={18} />
          </button>
          <button className="icon-button framed" type="button" aria-label="关闭任务设置" onClick={onClose}>
            <X aria-hidden="true" size={20} />
          </button>
        </div>
      </header>

      <SettingsGroup title="外观">
        <div className="theme-switch" role="group" aria-label="外观">
          <button
            className={settings.theme === "light" ? "selected" : ""}
            type="button"
            onClick={() => onSettingsChange({ theme: "light" })}
          >
            浅色
          </button>
          <button
            className={settings.theme === "dark" ? "selected" : ""}
            type="button"
            onClick={() => onSettingsChange({ theme: "dark" })}
          >
            深色
          </button>
        </div>
      </SettingsGroup>

      <SettingsGroup title="桌面">
        <label className="switch-row">
          <span>登录时启动</span>
          <input
            type="checkbox"
            checked={settings.launchAtLogin}
            onChange={(event) => onSettingsChange({ launchAtLogin: event.currentTarget.checked })}
          />
        </label>
      </SettingsGroup>

      <SettingsGroup title="窗口">
        <SliderSet sliders={windowSliders} settings={settings} onSettingsChange={onSettingsChange} />
      </SettingsGroup>

      <SettingsGroup title="把手">
        <SliderSet sliders={handleSliders} settings={settings} onSettingsChange={onSettingsChange} />
      </SettingsGroup>

      <SettingsGroup title="任务">
        <SliderSet sliders={taskSliders} settings={settings} onSettingsChange={onSettingsChange} />
      </SettingsGroup>

      <SettingsGroup title="手感">
        <SliderSet sliders={feelSliders} settings={settings} onSettingsChange={onSettingsChange} />
      </SettingsGroup>
    </div>
  );
}

function SettingsGroup({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="settings-group">
      <h2>{title}</h2>
      {children}
    </section>
  );
}

function SliderSet({
  sliders,
  settings,
  onSettingsChange,
}: {
  sliders: SliderConfig[];
  settings: TodobarSettings;
  onSettingsChange: (settings: Partial<TodobarSettings>) => void;
}) {
  return (
    <>
      {sliders.map((slider) => {
        const value = Number(settings[slider.key]);

        return (
          <label className="slider-row" key={slider.key}>
            <span>
              {slider.label}
              <strong>
                {value}
                {slider.unit}
              </strong>
            </span>
            <input
              type="range"
              min={slider.min}
              max={slider.max}
              step={slider.step}
              value={value}
              onChange={(event) =>
                onSettingsChange({ [slider.key]: Number(event.currentTarget.value) } as Partial<TodobarSettings>)
              }
            />
          </label>
        );
      })}
    </>
  );
}

function IconFor({ name, size }: { name: SectionIcon; size: number }) {
  if (name === "clock") {
    return <Clock3 aria-hidden="true" size={size} />;
  }

  if (name === "calendar") {
    return <CalendarDays aria-hidden="true" size={size} />;
  }

  return <ListChecks aria-hidden="true" size={size} />;
}

function Backdrop() {
  return (
    <div className="backdrop" aria-hidden="true">
      <div className="mock-window">
        <div />
        <div />
        <div />
      </div>
      <p>专注模式</p>
      <Archive size={22} />
    </div>
  );
}

function useLocalStorageState<T>(key: string, createDefault: () => T) {
  const [state, setState] = useState<T>(() => {
    const fallback = createDefault();

    try {
      const stored = window.localStorage.getItem(key);
      return stored ? ({ ...fallback, ...JSON.parse(stored) } as T) : fallback;
    } catch {
      return fallback;
    }
  });

  useEffect(() => {
    window.localStorage.setItem(key, JSON.stringify(state));
  }, [key, state]);

  return [state, setState] as const;
}
