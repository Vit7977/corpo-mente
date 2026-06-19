import argon2 from "argon2";
import "dotenv/config";

const PEPPER = process.env.PEPPER;

export const hashPass = async (pass) => {
  return await argon2.hash(pass + PEPPER, {
    type: argon2.argon2id,
    memoryCost: 2 ** 16,
    parallelism: 4,
    timeCost: 3,
  });
};

export const validatePass = async (hash, password) => {
  return await argon2.verify(hash, password + PEPPER);
};
