# frozen_string_literal: true

SimpleForm.setup do |config|
  config.button_class = "rounded-lg bg-blue-700 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300"
  config.boolean_label_class = "ms-2 text-sm font-medium text-gray-900"
  config.boolean_style = :inline
  config.browser_validations = false
  config.error_method = :to_sentence
  config.error_notification_class = "mb-4 rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-800"
  config.input_field_error_class = "border-red-500 bg-red-50 text-red-900 placeholder-red-700 focus:border-red-500 focus:ring-red-500"
  config.input_field_valid_class = "border-green-500 bg-green-50 text-green-900 placeholder-green-700 focus:border-green-500 focus:ring-green-500"
  config.item_wrapper_tag = :div
  config.label_text = lambda { |label, required, _explicit_label| "#{label} #{required}" }
  config.include_default_input_wrapper_class = false

  text_input_class = "block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500"
  label_class = "mb-2 block text-sm font-medium text-gray-900"
  error_class = "mt-2 text-sm text-red-600"
  hint_class = "mt-2 text-sm text-gray-500"
  checkbox_class = "h-4 w-4 rounded-sm border-gray-300 bg-gray-100 text-blue-600 focus:ring-2 focus:ring-blue-500"

  config.wrappers :tailwind_form, class: "mb-5" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: label_class
    b.use :input, class: text_input_class, error_class: config.input_field_error_class, valid_class: config.input_field_valid_class
    b.use :full_error, wrap_with: { tag: :p, class: error_class }
    b.use :hint, wrap_with: { tag: :p, class: hint_class }
  end

  config.wrappers :tailwind_boolean, class: "mb-5" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :checkbox_wrapper, class: "flex items-center" do |bb|
      bb.use :input, class: checkbox_class, error_class: config.input_field_error_class, valid_class: config.input_field_valid_class
      bb.use :label, class: config.boolean_label_class
    end
    b.use :full_error, wrap_with: { tag: :p, class: error_class }
    b.use :hint, wrap_with: { tag: :p, class: hint_class }
  end

  config.wrappers :tailwind_collection, item_wrapper_class: "flex items-center", item_label_class: config.boolean_label_class, tag: "fieldset", class: "mb-5" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: label_class do |ba|
      ba.use :label_text
    end
    b.use :input, class: checkbox_class, error_class: config.input_field_error_class, valid_class: config.input_field_valid_class
    b.use :full_error, wrap_with: { tag: :p, class: error_class }
    b.use :hint, wrap_with: { tag: :p, class: hint_class }
  end

  config.wrappers :tailwind_select, class: "mb-5" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: label_class
    b.use :input, class: text_input_class, error_class: config.input_field_error_class, valid_class: config.input_field_valid_class
    b.use :full_error, wrap_with: { tag: :p, class: error_class }
    b.use :hint, wrap_with: { tag: :p, class: hint_class }
  end

  config.default_wrapper = :tailwind_form
  config.wrapper_mappings = {
    boolean: :tailwind_boolean,
    check_boxes: :tailwind_collection,
    file: :tailwind_form,
    radio_buttons: :tailwind_collection,
    range: :tailwind_form,
    select: :tailwind_select
  }
end
