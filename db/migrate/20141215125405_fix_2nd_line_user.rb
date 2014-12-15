class Fix2ndLineUser < Mongoid::Migration
  # Clear up this legacy dummy user account that was used by the
  # mainstream_slug_updater rake task.  This user had no uid, and wasn't linked
  # to signon.
  #
  # Assign a random uid, and disable the user.
  def self.up
    if user = User.where(:name => "2nd Line Support").first
      user.uid = SecureRandom.uuid
      user.disabled = true
      user.save!
    else
      puts "2nd line user not found, skipping"
    end
  end

  def self.down
  end
end
