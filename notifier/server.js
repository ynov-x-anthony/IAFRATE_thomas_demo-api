import express from "express";

const app = express();
const PORT = process.env.PORT || 4000;

app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "UP" });
});

app.post("/notify", (req, res) => {
  console.log(`[notifier] nouveau produit : ${JSON.stringify(req.body)}`);
  res.status(202).json({ received: true });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[notifier] démarré sur le port ${PORT}`);
});
