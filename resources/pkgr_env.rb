default_action :set

allowed_actions :set, :scale

attribute :name, :kind_of => String # Application Name
attribute :key, :kind_of => String
attribute :value, :kind_of => String
