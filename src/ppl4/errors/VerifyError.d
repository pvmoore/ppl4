module ppl4.errors.VerifyError;

import ppl4.all;

final class VerifyError : Exception {
    this() {
        super("Verify error");
    }
}