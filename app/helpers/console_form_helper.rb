# Forms in the console put the label beside the field from md up (see the console_horizontal
# wrappers in config/initializers/simple_form.rb). Below md they stack, like the other forms.
module ConsoleFormHelper
  WRAPPER_MAPPINGS = { select: :console_horizontal_select }.freeze

  def console_form_for(record, options = {}, &)
    simple_form_for(record, { wrapper: :console_horizontal, wrapper_mappings: WRAPPER_MAPPINGS }.merge(options), &)
  end

  # A row with a label but no input, such as a value that can't be edited.
  def console_form_static_row(label, &)
    tag.div(class: "mb-5 md:grid md:grid-cols-[12rem_minmax(0,1fr)] md:items-start md:gap-x-4") do
      tag.p(label, class: "mb-2 block text-sm font-medium text-gray-900 md:mb-0 md:pt-2.5") + tag.div(class: "md:pt-2.5", &)
    end
  end

  # Submit and cancel, centered under the whole form.
  def console_form_actions(&)
    tag.div(class: "flex justify-center gap-2 pt-2", &)
  end
end
