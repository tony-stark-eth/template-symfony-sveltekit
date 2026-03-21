<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('framework', [
        'secret' => '%env(APP_SECRET)%',
        'http_method_override' => false,
        'handle_all_throwables' => true,
        'php_errors' => ['log' => true],
        'session' => [
            'handler_id' => null,
            'cookie_secure' => 'auto',
            'cookie_samesite' => 'lax',
            'storage_factory_id' => 'session.storage.factory.native',
        ],
        'serializer' => [
            'enabled' => true,
            'enable_attributes' => true,
        ],
        'validation' => [
            'enabled' => true,
            'enable_attributes' => true,
        ],
        'translator' => [
            'default_path' => '%kernel.project_dir%/translations',
            'fallbacks' => ['en'],
        ],
    ]);

    if ($container->env() === 'test') {
        $container->extension('framework', [
            'test' => true,
            'session' => [
                'storage_factory_id' => 'session.storage.factory.mock_file',
            ],
        ]);
    }
};
