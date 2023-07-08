ARG BASE_IMG=alpine

FROM $BASE_IMG as base

RUN echo "hello world!"
