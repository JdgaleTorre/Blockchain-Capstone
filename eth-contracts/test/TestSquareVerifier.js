var Verifier = artifacts.require("Verifier");

contract("Verifier", (accounts) => {
  const account_one = accounts[0];
  let proof = require("./proof");

  describe("test square verifier - zokrates", function () {
    beforeEach(async function () {
      contract = await Verifier.new({ from: account_one });
    });

    // Test verification with correct proof
    // - use the contents from proof.json generated from zokrates steps
    it("Test verification with correct proof", async function () {
      const {
        proof: { a, b, c },
        inputs: inputs,
      } = proof;
      let isCorrect = await contract.verifyTx({ a, b, c }, inputs, {
        from: account_one,
      });

      assert.equal(true, isCorrect, "Invalid proof result");
    });

    // Test verification with incorrect proof
    it("Test verification with incorrect proof", async function () {
      const {
        proof: { a, b, c },
      } = proof;
      let isCorrect = await contract.verifyTx({ a, b, c }, [5, 6], {
        from: account_one,
      });

      assert.equal(false, isCorrect, "Invalid proof result");
    });
  });
});
