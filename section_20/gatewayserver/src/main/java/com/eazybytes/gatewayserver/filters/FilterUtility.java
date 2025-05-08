package com.eazybytes.gatewayserver.filters;

import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;

import java.util.UUID;

@Component
public class FilterUtility {

    public static final String CORRELATION_ID = "eazybank-correlation-id";

    public String getCorrelationId(HttpHeaders requestHeaders) {
        return requestHeaders.getFirst(CORRELATION_ID);
    }

    public ServerWebExchange setCorrelationId(ServerWebExchange exchange, String correlationId) {
        return exchange.mutate().request(exchange.getRequest().mutate().header(CORRELATION_ID, correlationId).build()).build();
    }

    public String generateCorrelationId() {
        return UUID.randomUUID().toString();
    }
}