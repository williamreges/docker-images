package com.example.kafkateste.adapter.web;

import com.example.kafkateste.core.domain.PaymentDTO;
import com.example.kafkateste.core.port.in.PaymentExtratoUseCasePort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentExtratoController {

    private final PaymentExtratoUseCasePort paymentExtratoUseCasePort;

    @PostMapping
    public void teste(@RequestBody PaymentDTO dto) {
        paymentExtratoUseCasePort.paymentExtrato(dto);
    }

}
