export const componentTypes = ['Welcome'] as const;

export type ComponentType = typeof componentTypes[number];
