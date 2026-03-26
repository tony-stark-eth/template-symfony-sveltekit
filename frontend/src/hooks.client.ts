import { openobserveLogs } from '@openobserve/browser-logs';
import { openobserveRum } from '@openobserve/browser-rum';
import type { HandleClientError } from '@sveltejs/kit';

const O2_ENDPOINT = import.meta.env.VITE_O2_ENDPOINT;
const O2_ORG = import.meta.env.VITE_O2_ORG || 'default';
const O2_STREAM = import.meta.env.VITE_O2_STREAM || 'frontend';

if (O2_ENDPOINT) {
	openobserveLogs.init({
		clientToken: O2_STREAM,
		site: O2_ENDPOINT,
		organizationIdentifier: O2_ORG,
		apiVersion: 'v1',
		service: 'smart-habit-frontend',
		env: import.meta.env.MODE,
		forwardErrorsToLogs: true,
		insecureHTTP: false,
	});

	openobserveRum.init({
		applicationId: 'smart-habit-frontend',
		clientToken: O2_STREAM,
		site: O2_ENDPOINT,
		organizationIdentifier: O2_ORG,
		apiVersion: 'v1',
		service: 'smart-habit-frontend',
		env: import.meta.env.MODE,
		trackUserInteractions: true,
		trackResources: true,
		insecureHTTP: false,
	});
}

export const handleError: HandleClientError = ({ error, event, status, message }) => {
	if (O2_ENDPOINT) {
		openobserveLogs.logger.error('Unhandled error', {
			url: event.url.pathname,
			status,
			message,
			error: error instanceof Error ? error.message : String(error),
			stack: error instanceof Error ? error.stack : undefined,
		});
	}

	console.error(error);

	return {
		message: 'An unexpected error occurred.',
	};
};
