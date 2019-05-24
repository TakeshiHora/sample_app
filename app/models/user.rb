class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, 
    through: :active_relationships, 
    source: :followed
  has_many :followers, 
    through: :passive_relationships, 
    source: :follower
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  
    def self.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  
    # ランダムなトークンを返す
    def self.new_token
      SecureRandom.urlsafe_base64
    end
  
  
    # 永続セッションのためにユーザーをデータベースに記憶する
    def remember
      self.remember_token = User.new_token
      self.update_attribute(:remember_digest, User.digest(remember_token))
    end
    
      # ユーザーのログイン情報を破棄する
    def forget
      self.update_attribute(:remember_digest, nil)
    end
    
    def authenticated?(remember_token)
      return false if remember_digest.nil?
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  
    # 試作feedの定義
    # 完全な実装は次章の「ユーザーをフォローする」を参照
    def feed
      following_ids = "SELECT followed_id FROM relationships
                       WHERE follower_id = :user_id"
      Micropost.where("user_id IN (#{following_ids})
                       OR user_id = :user_id", user_id: id)
    end
  
    # ユーザーをフォローする
    def follow(other_user)
      following << other_user
    end

  # ユーザーをフォロー解除する
    def unfollow(other_user)
      self.active_relationships.find_by(followed_id: other_user.id).destroy
    end

  # 現在のユーザーがフォローしてたらtrueを返す
    def following?(other_user)
      self.following.include?(other_user)
    end
    
  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = self.email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(self.activation_token)
    end
  
end