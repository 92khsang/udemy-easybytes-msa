package com.eazybytes.accounts.service.client;

import com.eazybytes.accounts.dto.LoansDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient("loans")
public interface LoansFeignClient {

    @GetMapping(value = "/api/fetch", consumes = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity<LoansDto> fetchLoanDetails(@RequestParam String mobileNumber);

}
