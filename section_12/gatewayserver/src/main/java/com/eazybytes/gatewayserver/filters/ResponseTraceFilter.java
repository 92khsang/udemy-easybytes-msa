package com.eazybytes.gatewayserver.filters;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import reactor.core.publisher.Mono;

import java.util.Objects;

@Configuration
public class ResponseTraceFilter {

    private static final Logger logger = LoggerFactory.getLogger(ResponseTraceFilter.class);
    private final FilterUtility filterUtility;

    public ResponseTraceFilter(FilterUtility filterUtility) {
        this.filterUtility = filterUtility;
    }

    @Bean
    public GlobalFilter postGlobalFilter() {
        return (exchange, chain) -> chain.filter(exchange).then(Mono.fromRunnable(() -> {
            HttpHeaders requestHeaders = exchange.getRequest().getHeaders();
            String correlationId = filterUtility.getCorrelationId(requestHeaders);

            if (Objects.nonNull(correlationId) && !exchange.getResponse().getHeaders().containsKey(FilterUtility.CORRELATION_ID)) {
                logger.debug("Adding correlation ID to response headers: {}", correlationId);
                exchange.getResponse().getHeaders().add(FilterUtility.CORRELATION_ID, correlationId);
            }
        }));
    }
}