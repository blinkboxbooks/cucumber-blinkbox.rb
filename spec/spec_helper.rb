$:<<File.join(File.dirname(__FILE__), "..", "lib")

# Modules under test register themselves with Cucumber by passing themselves to
# World(m) Since Cucumber doesn't exist in test scope, however, we need to
# create a noop World
def World(m) end
