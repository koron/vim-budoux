# BudouX for Vim (experimental)

## Getting Started

```vimscript
:let m = budoux#load_japanese_model()

:echo m.parse('あなたに寄り添う最先端のテクノロジー')
['あなたに', '寄り添う', '最先端の', 'テクノロジー']
```

## Notes

* The models are copied from <https://github.com/google/budoux/tree/main/budoux/models>
* JSON model files are formated
* [Original BudouX demo site](https://google.github.io/budoux/)
