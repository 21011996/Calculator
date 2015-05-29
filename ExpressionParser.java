package ru.ifmo.md.lesson4;
//took this from prev year's java course
public class ExpressionParser implements CalculationEngine {
    static private String current;
    static private Lexer lex;
    static int balance;

    static private class Lexer {
        private final String s;
        private int cur;

        Lexer(String s) {
            this.s = s;
            cur = 0;
        }

        String next() throws CalculationException {
            boolean point = false;
            if (cur == s.length()) {
                return "";
            }
            if (Character.isDigit(s.charAt(cur))) {
                int j = cur;
                if (j+1<s.length() && Character.isDigit(s.charAt(j+1)) && s.charAt(j) == '0') {
                    throw new CalculationException("Incorrect expression");
                }
                while (j + 1 < s.length() && (Character.isDigit(s.charAt(j + 1)) || s.charAt(j+1) == '.')) {
                    if (s.charAt(j+1) == '.') {
                        if (!point) {
                            point = true;
                        } else throw new CalculationException("Incorrect expression");
                    }
                    j++;
                }
                int buff = cur;
                cur = j + 1;
                return s.substring(buff, j + 1);
            }
            cur++;
            return s.substring(cur - 1, cur);
        }
    }

    static private double parseValue() throws CalculationException {
        if (current.charAt(0) >= '0' && current.charAt(0) <= '9') {
            return Double.parseDouble(current);
        } else if (current.equals("(")) {
            balance++;
            return parseExpr();
        } else {
            throw new CalculationException("Incorrect expression");
        }
    }

    static private double parseMultiplier() throws CalculationException {
        current = lex.next();
        if (current.equals("")) {
            throw new CalculationException("Incorrect expression");
        }
        if (current.equals("-")) {
            return -parseMultiplier();
        }
        if (current.equals("+")) {
            return Math.abs(parseMultiplier());
        }
        return parseValue();
    }

    static private double parseSum() throws CalculationException {
        double left = parseMultiplier();
        while (true) {
            current = lex.next();
            if (!current.equals("*") && !current.equals("/") && !current.equals("%")) {
                return left;
            }
            if (current.equals("*")) {
                left = left * parseMultiplier();
            }
            if (current.equals("/")) {
                double right = parseMultiplier();
                if (right == 0) {
                    throw new CalculationException("Division by zero");
                } else
                left = left / right;
            }
        }
    }

    static private double parseExpr() throws CalculationException {
        double left = parseSum();
        while (true) {
            if (current.equals(")")) {
                balance--;
                return left;
            }
            if (current.equals("")) {
                return left;
            }
            switch (current.charAt(0)) {
                case '+': {
                    left = left + parseSum();
                    break;
                }
                case '-': {
                    left = left - parseSum();
                    break;
                }
            }
        }
    }
    @Override
    public double calculate(String expr) throws CalculationException {
        balance = 0;
        lex = new Lexer(expr);
        double result = parseExpr();
        if (balance!=0) {
            throw new CalculationException("Incorrect expression");
        } else
        return result;
    }
}