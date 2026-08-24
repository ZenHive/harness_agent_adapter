%Doctor.Config{
  # No ignore_paths: every module lives in `lib/` (the testing scaffolding
  # included, since ConformanceCase is shipped surface), so all of it is held
  # to the documentation bar below.
  ignore_paths: [],

  # Project standard: 100% documentation coverage on all public modules
  min_module_doc_coverage: 100,
  min_module_spec_coverage: 100,
  min_overall_doc_coverage: 100,
  min_overall_moduledoc_coverage: 100,
  min_overall_spec_coverage: 100,
  struct_type_spec_required: true,
  exception_moduledoc_required: true,
  raise: true,
  reporter: Doctor.Reporters.Full
}
