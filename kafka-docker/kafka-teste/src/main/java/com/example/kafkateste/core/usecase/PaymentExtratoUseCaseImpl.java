package com.example.kafkateste.core.usecase;

import com.example.kafkateste.core.domain.PaymentDTO;
import com.example.kafkateste.core.port.in.PaymentExtratoUseCasePort;
import com.example.kafkateste.core.port.out.PaymentExtratoProducerPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PaymentExtratoUseCaseImpl implements PaymentExtratoUseCasePort {

    private final PaymentExtratoProducerPort paymentExtratoProducerPort;

    @Override
    public void paymentExtrato(PaymentDTO paymentDTO) {
        paymentExtratoProducerPort.paymentExtratoProducer(paymentDTO);
    }
}
