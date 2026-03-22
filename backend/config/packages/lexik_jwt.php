<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('lexik_jwt_authentication', [
        'secret_key' => '%kernel.project_dir%/config/jwt/private.pem',
        'public_key' => '%kernel.project_dir%/config/jwt/public.pem',
        'pass_phrase' => '%env(JWT_PASSPHRASE)%',
        'token_ttl' => '%env(int:JWT_TOKEN_TTL)%',
    ]);
};
