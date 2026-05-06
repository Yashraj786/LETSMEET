# frozen_string_literal: true

# Base policy — all platform access defaults to DENY.
# Every policy explicitly overrides only the actions it permits.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    # Unauthenticated access is always denied at the policy layer
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user   = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  # Admins see all records in scope; members see nothing by default
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      user.role_admin? ? scope.all : scope.none
    end

    private

    attr_reader :user, :scope
  end
end
