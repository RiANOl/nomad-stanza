require 'hydrochlorb'

class Nomad::Stanza::Serializer
  class << self
    def serialize(obj, indent: 2)
      raise ArgumentError, 'Nomad::Stanza::Job is required.' unless obj.is_a? Nomad::Stanza::Job

      builder = Hydrochlorb.build do
        instance_eval &build_proc(obj, 'job', obj.id)
      end.to_hcl(indent: indent)
    end

    def build_proc(obj, key, id = nil)
      proc do
        add *[key, id].compact do
          obj.class.schema.each do |key|
            k = key.name
            v = obj.attributes[k]
            if k == :id or v.nil?
              next
            elsif v.is_a? Nomad::Stanza::Base
              if v.class.has_attribute?(:id)
                instance_eval &build_proc(v, k, v.id)
              else
                instance_eval &build_proc(v, k)
              end
            elsif v.is_a? Array
              member = obj.class.schema.key(k).type.type.member
              if member.is_a? Class and member.ancestors.include? Nomad::Stanza::Base
                v.each do |i|
                  if i.class.has_attribute?(:id)
                    instance_eval &build_proc(i, k, i.id)
                  else
                    instance_eval &build_proc(i, k)
                  end
                end
              else
                add k, v
              end
            else
              add k, v
            end
          end
        end
      end
    end
  end
end
