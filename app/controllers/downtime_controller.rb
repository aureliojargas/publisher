class DowntimeController < InheritedResources::Base

  def index
    @transactions = Edition.where(_type: 'TransactionEdition', state: 'published')
  end

  def schedule
    get_transaction
  end

  def scheduled
    get_transaction
  end

  def unplanned
    get_transaction
  end

  def liveunplanned
    get_transaction
  end

  private

  def get_transaction
    @transaction = Edition.where(_type: 'TransactionEdition', state: 'published').first
  end

end
