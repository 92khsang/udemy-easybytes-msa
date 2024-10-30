package com.eazybytes.gatewayserver.config;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.*;
import java.util.stream.Collectors;

public class KeycloakRoleConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

    private static final String ROLE_PREFIX = "ROLE_";

    @Override
    public Collection<GrantedAuthority> convert(Jwt source) {
        Map<String, Object> realmAccess = (Map<String, Object>) source.getClaims().get("realm_access");
        if (Objects.isNull(realmAccess) || realmAccess.isEmpty()) {
            return Collections.emptyList();
        }

        List<String> roles = Optional.ofNullable((List<String>) realmAccess.get("roles"))
                .orElse(Collections.emptyList());

        return roles.stream()
                .map(roleName -> ROLE_PREFIX + roleName)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }
}
