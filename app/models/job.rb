class Job < ActiveRecord::Base
  include States::Base
  
  Scheduled   = 'scheduled'
  Transcoding = 'transcoding'
  Processing  = 'processing'
  OnHold      = 'on_hold'
  Success     = 'success'
  Failed      = 'failed'
  
  belongs_to :preset
  belongs_to :host

  default_scope :order => ["created_at DESC"]
  scope :scheduled,   :conditions => { :state => Scheduled }
  scope :transcoding, :conditions => { :state => Transcoding }  
  scope :on_hold,     :conditions => { :state => OnHold }
  scope :success,     :conditions => { :state => Success }
  scope :failed,      :conditions => { :state => Failed }
  
  validates :source_file, :destination_file, :preset_id, :presence => true
  
  def self.from_api(options)
    new(:source_file => options['input'],
        :destination_file => options['output'],
        :preset => Preset.find_by_name(options['preset']))
  end
  
  def update_status
    if attrs = Transcoder.job_status(self)
      enter(attrs['status'], attrs)
    end
    self
  end
end
