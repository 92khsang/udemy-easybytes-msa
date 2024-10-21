package com.eazybytes.loans.exception;

import com.eazybytes.loans.dto.ErrorResponseDto;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException exception,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request
    ) {
        Map<String, String> errorOutput = new HashMap<>();
        List<ObjectError> invalidArguments = exception.getBindingResult().getAllErrors();

        invalidArguments.forEach((invalidArgument) -> {
            String fieldName = ((FieldError) invalidArgument).getField();
            String message = invalidArgument.getDefaultMessage();
            errorOutput.put(fieldName, message);
        });

        return ResponseEntity.badRequest().body(errorOutput);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponseDto> handleGlobalException(
        Exception exception, WebRequest webRequest) {
        return createErrorResponseEntity(
                HttpStatus.INTERNAL_SERVER_ERROR,
                webRequest.getDescription(false),
                exception.getMessage()
        );
    }

    @ExceptionHandler(LoanAlreadyExistsException.class)
    public ResponseEntity<ErrorResponseDto> handleLoanAlreadyExistsException(
        LoanAlreadyExistsException exception, WebRequest webRequest) {

        return createErrorResponseEntity(
                HttpStatus.BAD_REQUEST,
                webRequest.getDescription(false),
                exception.getMessage()
        );
    }

    private ResponseEntity<ErrorResponseDto> createErrorResponseEntity(
            HttpStatus status,
            String description,
            String message
    ) {
        return new ResponseEntity<>(
            new ErrorResponseDto(
                description,
                status,
                message,
                LocalDateTime.now()
            ),
            status
        );
    }
}
