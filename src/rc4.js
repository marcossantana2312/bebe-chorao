const KEY = "123";

function S_SWAP(S, a, b) {
    const t = S[a];
    S[a] = S[b];
    S[b] = t;
}

const rc4 = (plaintext) => {
    let result = '';
    const S = [];

    for (let i = 0; i < 256; i++) {
        S[i] = i;
    }

    // KSA
    for (let j = 0, i = 0; i < 256; i++) {
        j = (j + (S[i]) + (KEY.charCodeAt([i % KEY.length]))) % 256;
        S_SWAP(S, S[i], S[j]);
    }

    // PRGA
    for (let i = 0, j = 0, k = 0; k < plaintext.length; k++) {
        i = (i + 1) % 256;
        j = (j + S[i]) % 256;
        S_SWAP(S, S[i], S[j]);
        result += String.fromCharCode(plaintext.charCodeAt(k) ^ S[(S[i] + S[j]) % 256]);
    }

    return result;
}
module.exports = rc4;