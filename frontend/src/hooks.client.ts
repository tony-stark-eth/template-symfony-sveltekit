import * as Sentry from '@sentry/svelte';
import type { HandleClientError } from '@sveltejs/kit';

const SENTRY_DSN = import.meta.env.VITE_SENTRY_DSN;

if (SENTRY_DSN) {
	Sentry.init({
		dsn: SENTRY_DSN,
		environment: import.meta.env.MODE,
		tracesSampleRate: 0,
	});
}

export const handleError: HandleClientError = ({ error, event, status, message }) => {
	if (SENTRY_DSN) {
		Sentry.captureException(error, {
			extra: { url: event.url.pathname, status, message },
		});
	}

	console.error(error);

	return {
		message: 'An unexpected error occurred.',
	};
};
