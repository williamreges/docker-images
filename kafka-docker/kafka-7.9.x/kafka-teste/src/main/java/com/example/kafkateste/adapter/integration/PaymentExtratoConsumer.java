package com.example.kafkateste.adapter.integration;

import com.example.kafkateste.core.domain.Payment;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class PaymentExtratoConsumer {

    @KafkaListener(topics = "${topic.payment-extrato}", groupId = "group_id")
    public void consumer(ConsumerRecord<String, Payment> record, Acknowledgment ack) {

        var payment = record.value();

        log.info(payment.toString());
        ack.acknowledge();
    }
}
