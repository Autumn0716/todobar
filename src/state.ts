export type Theme = "light" | "dark";
export type SectionIcon = "clock" | "calendar" | "list";

export type Task = {
  id: string;
  title: string;
  meta: string;
  completed: boolean;
  focus?: boolean;
};

export type Section = {
  id: string;
  title: string;
  icon: SectionIcon;
  addPlaceholder: string;
  tasks: Task[];
  collapsed: boolean;
};

export type TodobarSettings = {
  theme: Theme;
  launchAtLogin: boolean;
  panelWidth: number;
  visibleTab: number;
  buttonHeight: number;
  verticalPosition: number;
  rowHeight: number;
  rowGap: number;
  textSize: number;
  motionMs: number;
  cornerRadius: number;
  surfaceOpacity: number;
};

export type TodobarBoard = {
  sections: Record<string, Section>;
  sectionOrder: string[];
  customListIds: string[];
  settings: TodobarSettings;
  panelOpen: boolean;
  settingsOpen: boolean;
};

export const defaultSettings: TodobarSettings = {
  theme: "light",
  launchAtLogin: true,
  panelWidth: 348,
  visibleTab: 34,
  buttonHeight: 72,
  verticalPosition: 16,
  rowHeight: 41,
  rowGap: 7,
  textSize: 12.5,
  motionMs: 230,
  cornerRadius: 18,
  surfaceOpacity: 96,
};

export function createInitialBoard(): TodobarBoard {
  return {
    sections: {
      today: {
        id: "today",
        title: "今天",
        icon: "clock",
        addPlaceholder: "添加任务...",
        collapsed: false,
        tasks: [
          {
            id: "task-design-sidebar-shell",
            title: "设计侧边栏外壳",
            meta: "今天 · 40 分钟",
            completed: false,
            focus: true,
          },
          {
            id: "task-prototype-desktop-shortcut",
            title: "原型化桌面快捷入口",
            meta: "今天 · 原生钩子",
            completed: false,
          },
          {
            id: "task-test",
            title: "测试",
            meta: "今天",
            completed: true,
          },
          {
            id: "task-capture-inbox",
            title: "捕获收件箱",
            meta: "快速添加",
            completed: true,
          },
        ],
      },
      month: {
        id: "month",
        title: "月计划",
        icon: "calendar",
        addPlaceholder: "添加月任务...",
        collapsed: false,
        tasks: [
          {
            id: "task-open-source-roadmap",
            title: "开源路线图",
            meta: "五月 · 里程碑 0.1",
            completed: false,
            focus: true,
          },
          {
            id: "task-later",
            title: "稍后",
            meta: "先把想法放在这里",
            completed: false,
          },
        ],
      },
      general: {
        id: "general",
        title: "通用",
        icon: "list",
        addPlaceholder: "添加任务...",
        collapsed: false,
        tasks: [],
      },
    },
    sectionOrder: ["today", "month", "general"],
    customListIds: ["general"],
    settings: defaultSettings,
    panelOpen: true,
    settingsOpen: false,
  };
}

export function addTask(board: TodobarBoard, sectionId: string, rawTitle: string): TodobarBoard {
  const title = rawTitle.trim();
  const section = board.sections[sectionId];

  if (!title || !section) {
    return board;
  }

  const task: Task = {
    id: uniqueId(`task-${slugify(title)}`, section.tasks.map((item) => item.id)),
    title,
    meta: sectionId === "month" ? "五月 · 已规划" : "今天",
    completed: false,
  };

  return updateSection(board, sectionId, {
    tasks: [...section.tasks, task],
  });
}

export function toggleTask(board: TodobarBoard, sectionId: string, taskId: string): TodobarBoard {
  const section = board.sections[sectionId];

  if (!section) {
    return board;
  }

  return updateSection(board, sectionId, {
    tasks: section.tasks.map((task) =>
      task.id === taskId ? { ...task, completed: !task.completed } : task,
    ),
  });
}

export function deleteTask(board: TodobarBoard, sectionId: string, taskId: string): TodobarBoard {
  const section = board.sections[sectionId];

  if (!section) {
    return board;
  }

  return updateSection(board, sectionId, {
    tasks: section.tasks.filter((task) => task.id !== taskId),
  });
}

export function toggleSection(board: TodobarBoard, sectionId: string): TodobarBoard {
  const section = board.sections[sectionId];

  if (!section) {
    return board;
  }

  return updateSection(board, sectionId, {
    collapsed: !section.collapsed,
  });
}

export function addCustomList(board: TodobarBoard, rawTitle: string): TodobarBoard {
  const title = rawTitle.trim();

  if (!title) {
    return board;
  }

  const id = uniqueId(slugify(title), board.sectionOrder);
  const section: Section = {
    id,
    title,
    icon: "list",
    addPlaceholder: "添加任务...",
    collapsed: false,
    tasks: [],
  };

  return {
    ...board,
    sections: {
      ...board.sections,
      [id]: section,
    },
    sectionOrder: [...board.sectionOrder, id],
    customListIds: [...board.customListIds, id],
  };
}

export function updateSettings(
  board: TodobarBoard,
  settings: Partial<TodobarSettings>,
): TodobarBoard {
  return {
    ...board,
    settings: {
      ...board.settings,
      ...settings,
    },
  };
}

export function replaceSettings(board: TodobarBoard, settings: TodobarSettings): TodobarBoard {
  return {
    ...board,
    settings,
  };
}

function updateSection(
  board: TodobarBoard,
  sectionId: string,
  patch: Partial<Section>,
): TodobarBoard {
  const section = board.sections[sectionId];

  if (!section) {
    return board;
  }

  return {
    ...board,
    sections: {
      ...board.sections,
      [sectionId]: {
        ...section,
        ...patch,
      },
    },
  };
}

function uniqueId(base: string, existingIds: string[]): string {
  const existing = new Set(existingIds);
  let candidate = base || "item";
  let suffix = 2;

  while (existing.has(candidate)) {
    candidate = `${base}-${suffix}`;
    suffix += 1;
  }

  return candidate;
}

function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
