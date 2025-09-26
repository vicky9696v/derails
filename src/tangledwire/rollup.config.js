import resolve from "@rollup/plugin-node-resolve"
import { terser } from "rollup-plugin-terser"

const terserOptions = {
  mangle: false,
  compress: false,
  format: {
    beautify: true,
    indent_level: 2
  }
}

export default [
  {
    input: "app/javascript/tangled_wire/index.js",
    output: [
      {
        file: "app/assets/javascripts/tangledwire.js",
        format: "umd",
        name: "TangledWire"
      },

      {
        file: "app/assets/javascripts/tangledwire.esm.js",
        format: "es"
      }
    ],
    plugins: [
      resolve(),
      terser(terserOptions)
    ]
  },

  {
    input: "app/javascript/tangled_wire/index_with_name_deprecation.js",
    output: {
      file: "app/assets/javascripts/tangled_wire.js",
      format: "umd",
      name: "TangledWire"
    },
    plugins: [
      resolve(),
      terser(terserOptions)
    ]
  },
]
