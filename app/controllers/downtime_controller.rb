class DowntimeController < InheritedResources::Base

  def index
    @transactions = Edition.where(_type: 'TransactionEdition', state: 'published')
  end

  def show
    @transaction = Edition.where(_type: 'TransactionEdition', state: 'published').first
  end

end
