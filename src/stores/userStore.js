import { writable } from 'svelte/store';

export const user = writable(null); // Initialize user as null (not logged in)
