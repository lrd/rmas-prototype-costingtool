require 'savon'

class ProposalsController < ApplicationController

  def process_message(msg)
    msg = ActiveSupport::JSON.decode(msg)

    case msg['message_type']
      when 'proposal_created' then

        puts 'Need to create proposal'
        data = msg['entity']
        rmas_id = data.delete('id')

        # does this proposal already exist?
        unless Proposal.where(:rmas_id => rmas_id).exists?
          # make new proposal
          data['rmas_id'] = rmas_id
          proposal = Proposal.new(data)
          proposal.save
        end

      when 'proposal_updated' then

        puts 'Need to update proposal'
        data = msg['entity']
        rmas_id = data.delete('id')

        proposal = Proposal.where(:rmas_id => rmas_id).first

        unless proposal.nil?
          proposal.update_attributes(data)
        end

      when 'proposal_deleted' then

        puts 'Need to archive a proposal'
        rmas_id = msg['entity']['id']

        Proposal.where(:rmas_id => rmas_id).update_all('archived = 1')
    end

  end

  # GET /proposals/sync
  def sync
    
    # poll for proposal messages
    client = Savon::Client.new do
      wsdl.document = 'http://129.12.9.208:6980/EventService?wsdl'
    end

    timestamp = Costingtool::Application.config.lastRmasPoll

    timestamp = (Time.now.utc - 2629743).iso8601 if timestamp.empty?

    response = client.request :get_events do
      soap.body = { :timestamp => timestamp }
    end

    Costingtool::Application.config.lastRmasPoll = Time.now.utc.iso8601

    unless response[:get_events_response][:return].nil?

      response_bit = response.to_hash[:get_events_response][:return][:string]

      if response_bit.respond_to?('each')
        response_bit.each {|msg| process_message(msg) }
      else
        process_message(response_bit)
      end

    end

    redirect_to params[:redir]

  end

  # GET /proposals
  # GET /proposals.json
  def index
    @proposals = Proposal.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @proposals }
    end
  end

  # GET /proposals/1
  # GET /proposals/1.json
  def show
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @proposal }
    end
  end

  # GET /proposals/new
  # GET /proposals/new.json
  def new
    @proposal = Proposal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @proposal }
    end
  end

  # GET /proposals/1/edit
  def edit
    @proposal = Proposal.find(params[:id])
  end

  # POST /proposals
  # POST /proposals.json
  def create
    @proposal = Proposal.new(params[:proposal])

    respond_to do |format|
      if @proposal.save
        format.html { redirect_to @proposal, notice: 'Proposal was successfully created.' }
        format.json { render json: @proposal, status: :created, location: @proposal }
      else
        format.html { render action: "new" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1
  # PUT /proposals/1.json
  def update
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      if @proposal.update_attributes(params[:proposal])
        format.html { redirect_to @proposal, notice: 'Proposal was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.json
  def destroy
    @proposal = Proposal.find(params[:id])
    @proposal.destroy

    respond_to do |format|
      format.html { redirect_to proposals_url }
      format.json { head :ok }
    end
  end
end
