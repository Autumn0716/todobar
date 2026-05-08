import { describe, expect, it } from "vitest";
import {
  addCustomList,
  addTask,
  createInitialBoard,
  deleteTask,
  toggleTask,
  updateSettings,
} from "./state";

describe("todobar state", () => {
  it("adds a task to the requested section", () => {
    const board = createInitialBoard();
    const updated = addTask(board, "today", "Write tests");

    expect(updated.sections.today.tasks).toHaveLength(board.sections.today.tasks.length + 1);
    expect(updated.sections.today.tasks.at(-1)).toMatchObject({
      title: "Write tests",
      completed: false,
    });
  });

  it("toggles and deletes tasks without mutating the original board", () => {
    const board = createInitialBoard();
    const taskId = board.sections.today.tasks[0].id;

    const toggled = toggleTask(board, "today", taskId);
    const deleted = deleteTask(toggled, "today", taskId);

    expect(board.sections.today.tasks[0].completed).toBe(false);
    expect(toggled.sections.today.tasks[0].completed).toBe(true);
    expect(deleted.sections.today.tasks.some((task) => task.id === taskId)).toBe(false);
  });

  it("creates custom lists with stable ids and empty task collections", () => {
    const board = createInitialBoard();
    const updated = addCustomList(board, "Deep Work");
    const created = updated.customListIds.map((id) => updated.sections[id]).at(-1);

    expect(created).toMatchObject({
      title: "Deep Work",
      icon: "list",
      tasks: [],
    });
  });

  it("updates settings by merging changed values", () => {
    const board = createInitialBoard();
    const updated = updateSettings(board, {
      theme: "dark",
      panelWidth: 420,
      motionMs: 120,
    });

    expect(updated.settings.theme).toBe("dark");
    expect(updated.settings.panelWidth).toBe(420);
    expect(updated.settings.motionMs).toBe(120);
    expect(updated.settings.rowHeight).toBe(board.settings.rowHeight);
  });
});
