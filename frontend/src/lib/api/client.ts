/**
 * Generic fetch wrapper for the Symfony API.
 *
 * Base URL: /api/v1 (relative — works via Vite proxy in dev and same-origin in prod).
 * Authentication: JWT access token sent as Authorization: Bearer header.
 * Token refresh: on 401, attempts a token refresh then retries the original request once.
 */

const BASE_URL = '/api/v1';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface ApiError {
    status: number;
    message: string;
    detail?: string;
}

export class ApiRequestError extends Error {
    readonly status: number;
    readonly detail?: string;

    constructor(error: ApiError) {
        super(error.message);
        this.name = 'ApiRequestError';
        this.status = error.status;
        if (error.detail !== undefined) {
            this.detail = error.detail;
        }
    }
}

// ---------------------------------------------------------------------------
// Token storage
// ---------------------------------------------------------------------------

/**
 * Retrieve the current JWT access token.
 * Replace this with your auth store (e.g. a Svelte 5 $state store).
 */
function getAccessToken(): string | null {
    return localStorage.getItem('access_token');
}

/**
 * Retrieve the current JWT refresh token.
 */
function getRefreshToken(): string | null {
    return localStorage.getItem('refresh_token');
}

/**
 * Persist new tokens after a successful refresh.
 */
function storeTokens(accessToken: string, refreshToken: string): void {
    localStorage.setItem('access_token', accessToken);
    localStorage.setItem('refresh_token', refreshToken);
}

/**
 * Clear all stored tokens (e.g. on logout or refresh failure).
 */
export function clearTokens(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
}

// ---------------------------------------------------------------------------
// Token refresh
// ---------------------------------------------------------------------------

interface RefreshResponse {
    token: string;
    refresh_token: string;
}

let refreshPromise: Promise<string> | null = null;

/**
 * Refresh the access token using the stored refresh token.
 * Deduplicates concurrent refresh attempts so only one request is made.
 */
async function refreshAccessToken(): Promise<string> {
    // Deduplicate concurrent 401s — all callers wait on the same promise.
    if (refreshPromise !== null) {
        return refreshPromise;
    }

    refreshPromise = (async (): Promise<string> => {
        const refreshToken = getRefreshToken();
        if (refreshToken === null) {
            throw new ApiRequestError({ status: 401, message: 'No refresh token available' });
        }

        const response = await fetch(`${BASE_URL}/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refresh_token: refreshToken }),
        });

        if (!response.ok) {
            clearTokens();
            throw new ApiRequestError({ status: 401, message: 'Token refresh failed' });
        }

        const data = (await response.json()) as RefreshResponse;
        storeTokens(data.token, data.refresh_token);
        return data.token;
    })().finally(() => {
        refreshPromise = null;
    });

    return refreshPromise;
}

// ---------------------------------------------------------------------------
// Core fetch helper
// ---------------------------------------------------------------------------

async function request<T>(
    method: string,
    path: string,
    body?: unknown,
    retry = true,
): Promise<T> {
    const url = `${BASE_URL}${path}`;

    const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        Accept: 'application/json',
    };

    const token = getAccessToken();
    if (token !== null) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const fetchInit: RequestInit = { method, headers };
    if (body !== undefined) {
        fetchInit.body = JSON.stringify(body);
    }

    const response = await fetch(url, fetchInit);

    // On 401, attempt a token refresh and retry the request once.
    if (response.status === 401 && retry) {
        try {
            await refreshAccessToken();
        } catch {
            throw new ApiRequestError({ status: 401, message: 'Authentication required' });
        }
        return request<T>(method, path, body, false);
    }

    if (!response.ok) {
        let message = `Request failed with status ${response.status}`;
        let detail: string | undefined;

        try {
            const errorBody = (await response.json()) as { message?: string; detail?: string };
            if (errorBody.message !== undefined) message = errorBody.message;
            if (errorBody.detail !== undefined) detail = errorBody.detail;
        } catch {
            // Ignore parse errors — use the default message above.
        }

        throw new ApiRequestError({
            status: response.status,
            message,
            ...(detail !== undefined ? { detail } : {}),
        });
    }

    // Return undefined for 204 No Content responses.
    if (response.status === 204) {
        return undefined as T;
    }

    return (await response.json()) as T;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

export const client = {
    get<T>(path: string): Promise<T> {
        return request<T>('GET', path);
    },

    post<T>(path: string, body?: unknown): Promise<T> {
        return request<T>('POST', path, body);
    },

    put<T>(path: string, body?: unknown): Promise<T> {
        return request<T>('PUT', path, body);
    },

    delete<T>(path: string): Promise<T> {
        return request<T>('DELETE', path);
    },
};
