# This module allows steps to set the subject of a scenario simply.
#
#     subject(:book, {"isbn" => "9780111222333"})
#     subject(:contributor, {"guid" => "abc123"})
#
#     p subject(:book)
#     # => {"isbn" => "9780111222333"}
#
# It's really just a readable wrapper for a hash with some test specific exceptions and things
module KnowsAboutGrammaticalSubjects
  SUBJECTS = {}
  USING_SETTER = :you_will_never_accidentally_pass_this

  def subject(type, details = USING_SETTER)
    if details == USING_SETTER
      raise "Test error: A #{type} subject hasn't been defined in this scenario yet." unless SUBJECTS[type]
      return SUBJECTS[type]
    else
      SUBJECTS[type] = details
    end
  end
end

World(KnowsAboutGrammaticalSubjects)

Before do
  KnowsAboutGrammaticalSubjects::SUBJECTS.clear
end