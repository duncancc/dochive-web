class DocumentsController < ApplicationController
  require 'RMagick'
  require 'fileutils'
  
  
  before_filter :authenticate_user!
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.where(user_id: current_user.id)
  end
    
  def data
    #
    # yep
    #
    @documents = Document.where(user_id: current_user.id)
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    #p "#{@document.source.url}"
    #p "#{@document.source.path}"
    @thumb =  "#{@document.source.url}".split("?")[0].gsub("/original/","/original/thumb/")
    @medium =  "#{@document.source.url}".split("?")[0].gsub("/original/","/original/medium/")
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
    #@documents = Document.where(user_id: current_user.id)
    @document = Document.find(params[:id], :conditions => {:user_id => current_user.id}) #bubu
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.create( document_params )
    @document.user_id = current_user.id
    #@document.description = params[:description]
    @document.description = document_params[:description]

    respond_to do |format|
      if @document.save
        separatePages(@document.id)           
        
        #format.html { redirect_to @document, notice: 'pdf upload successful' }
        format.html { redirect_to documents_url, notice: 'pdf upload successful' }
        format.json { render action: 'index', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'pdf update successful' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    
    directory_name = File.dirname("#{@document.source.path}")
    
    p "---------"
    p "---------"
    p "---------"
    p directory_name
    p "---------"
    p "---------"
    p "---------"
    
    #if File.directory?(directory_name) 
    #  FileUtils.rm_r directory_name
    #end
    
    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :no_content }
    end
  end
  
  def pages
    @document = Document.find(params[:id])
    @pages = Page.where("document_id = "+params[:id]).order("id asc")
  end
  
  def templates
    @document = Document.find(params[:id])
    @pages = Page.where("document_id = "+params[:id]+" and (template_id IS NOT NULL or template_id <> '0')").order("id asc")
  end
  
  def tembuil
    #@page = Page.where("id = #{params[:id]}")
    #@document = Document.find(@page.document_id)

    #redirect_to "/documents/#{params[:id]}"
  end
  
  def prepare
    #system("ls > alpha.txt")
    #system `ls > beta.txt`
    
    @document = Document.find(params[:id])

    trimLeft = 10
    filePath = "#{Rails.root}/public/system/documents/sources/000/000/026/original/Cooke_Dale_2012-05-25"
    fileName = "Cooke_Dale_2012-05-25"
    
    readFileExtension = ".pdf"
    writeFileExtension = ".png"
      
    counter = 0
 
    img1 = Magick::Image::read(filePath + "/" + fileName + readFileExtension) { 
      
      self.density = 300
      self.image_type = Magick::GrayscaleType
      
    }.each { |img1, i|  

      
      p "**************** start page ***************************************** #{counter+1} ****"  
      
      #todo: create directory(s)
      
      img1.write(filePath + "/img1/" + fileName + "-%02d-01" + writeFileExtension) { }
            
      img2 = img1.deskew("40%")   
      img2.write(filePath + "/img2/" + fileName + "-%02d-02" + writeFileExtension) { }
      
      img3 = img2.quantize(2, Magick::GRAYColorspace)
      img3.write(filePath + "/img3/" + fileName + "-%02d-02" + writeFileExtension) { }
      
      width = img3.columns
      height = img3.rows
      
      h = img3.scale(width, 25)
      w = img3.scale(25, height) 
      
      img4 = img3.crop(Magick::EastGravity,width-trimLeft,height)
      img4.fuzz = "5%"
      img4.write(filePath + "/img4/" + fileName + "-%02d-02" + writeFileExtension) { }
      
      img5 = img4.trim(true)
      img5.write(filePath + "/img5/" + fileName + "-%02d-02" + writeFileExtension) { }
      
      wdth = img5.columns
      hght = img5.rows
      
      #p "-~-~^-"
      
      h1A = img5.scale(wdth, 1)
      w1A = img5.scale(1, hght)
      
      h1A.write(filePath + "/H1/" + fileName + "-%02d-xH1A" + writeFileExtension) { }
      w1A.write(filePath + "/H1/" + fileName + "-%02d-xW1A" + writeFileExtension) { }
      
      h2A = h1A.scale(640, 25)
      w2A = w1A.scale(25, 640)
      
      h2A.write(filePath + "/H2/" + fileName + "-%02d-xH2A" + writeFileExtension) { }
      w2A.write(filePath + "/H2/" + fileName + "-%02d-xW2A" + writeFileExtension) { }
      
      h3A = h1A.scale(640, 1)
      w3A = w1A.scale(1, 640)
      
      h3A.write(filePath + "/H3/" + fileName + "-%02d-xH3A" + writeFileExtension) { }
      w3A.write(filePath + "/H3/" + fileName + "-%02d-xW3A" + writeFileExtension) { }
      
      h3A.write(filePath + "/H3txt/" + fileName + "-%02d-xH3A" + ".txt") { }
      w3A.write(filePath + "/H3txt/" + fileName + "-%02d-xW3A" + ".txt") { }

      #p "-~--~-"      
      
      #p "-^--~-"
      
      #p "--"
      
      (foo ||= []) << h3A.get_pixels(0, 0, 640, 1) 
      (fubar ||= [])  << w3A.get_pixels(0, 0, 1, 640)
      
      p "**************** new page *******************************************"  
      
      p "**************** foo array ******************************************"  
      @foo_array = Array.new
      foo.each { |x| 
        
        #p x
        #p ' sub A start         '
        harry = x.split(/\r?\n/).join().split()
        
        harry.each { |yoyo|
          temp = yoyo.match /red=\d{1,}/
          
          if (temp!=nil)
            limp = temp[0].partition('=').last
            #p limp.to_i
            @foo_array << limp.to_i
          end
          
        }                  
      }
      
      
      p "**************** fubar array ****************************************"  
      @fubar_array = Array.new
      fubar.each { |y| 
        
        #p x
        #p ' sub A start         '
        perry = y.split(/\r?\n/).join().split()
        
        perry.each { |bobo|
          temp = bobo.match /red=\d{1,}/
          
         if (temp!=nil)
            limp = temp[0].partition('=').last
            #p limp.to_i
            @fubar_array << limp.to_i
          end
          
        }                  
      }
      
      counter = counter + 1
      
      fn1 = filePath + "/intensity/" + fileName + "-int-" + counter.to_s + "-A.png"
      #p fn1
      
      fn2 = filePath + "/intensity/" + fileName + "-int-" + counter.to_s + "-B.png"
      #p fn2
      
      fn3 = filePath + "/intensity/" + fileName + "-int-" + counter.to_s + "-C.png"
      #p fn3
      
      Gchart.line(:data =>  @foo_array, 
                  :format => 'file', 
                :size => '640x200',
                  :line_colors => "FF0000",
                  :filename => fn1
                  )
      Gchart.line(:data =>  @fubar_array, 
                  :format => 'file', 
                  :size => '640x200',
                  :line_colors => "00FF00",
                  :filename => fn2
                  )
      Gchart.line(:data =>  [@foo_array,@fubar_array], 
                  :format => 'file', 
                  :size => '640x200',
                  :filename => fn3, 
                  :line_colors => "FF0000,00FF00",
                  :stacked => false#,
                  #:legend => ["Height", "Width"]
                            )
      

      p "-- PreGo ---------------------------->"
      p "  --->  "
      
      gc = Magick::Draw.new
      
      # Picture Section
      picture = img5
      width,height = picture.columns, picture.rows
      tss = img5
      cola = Magick::Draw.new
      
      @semplate = Semplate.first(:conditions => {:user_id => current_user.id}) #bubu
      @section = Section.all(:conditions => {:semplate_id => @semplate.id}) #bubu
      @section.each do |s3ct10n|
        tfb = img5.crop(s3ct10n.xOriginy,s3ct10n.yOrigin,s3ct10n.width,s3ct10n.height,true)
        tfb.write(filePath + "/crop/" + fileName + "_" + s3ct10n.name + "-%02d-crop" + writeFileExtension) { }

        #tss.write(filePath + "/locations/" + fileName + "_" + s3ct10n.name + "-%02d-locations" + writeFileExtension) { }
        p [s3ct10n.xOriginy,s3ct10n.yOrigin,s3ct10n.height,s3ct10n.width]
        #cola.rectangle(s3ct10n.xOriginy,s3ct10n.yOrigin,s3ct10n.height,s3ct10n.width)
        
        
        
        cola.fill("none")
        cola.stroke_width(3)
        cola.stroke("red")
        #cola.rectangle(s3ct10n.xOriginy,0,1000,10)
        cola.rectangle(s3ct10n.xOriginy,s3ct10n.yOrigin,s3ct10n.width+s3ct10n.xOriginy,s3ct10n.height+s3ct10n.yOrigin)
        cola.draw(tss)

        #cola.write(filePath + "/locations/" + fileName  + "-%02d-loco" + writeFileExtension) { }
        #tss.write(filePath + "/locations/" + fileName + "_" + s3ct10n.name + "-%02d-loco" + writeFileExtension) { }
        
        
        
        
        
        
        
        convertString = "tesseract " + filePath + "/crop/" + fileName + "_" + s3ct10n.name + "-0" + (counter-1).to_s + "-crop" + writeFileExtension + " " + filePath + "/tess/" + fileName + "_" + s3ct10n.name + "-0" + (counter-1).to_s + "-tess"                                
        p convertString
        system(convertString)
        
        
        
        
        
        
        
      end

      tss.write(filePath + "/locations/" + fileName  + "-%02d-locos" + writeFileExtension) { }
    
      p "  --->  "    
      p "-- EndGo ---------------------------->"
                
      p "**************** end page ******************************************* #{counter} ****"
                
      p "                                                                            "  
      
    }  
    p "-- Stop -------------------------->"
  
    redirect_to @document, flash: { referral_code: 1234 }    
    
  end
    
  def repage

    redirect_to "/pages/#{params[:id]}"
  end
  
  def ajaxdestroy
    p "aaahhhhh"
   #Document.find(@params[:id]).destroy
   #render :partial => "bookmarks"
  end

  def ajaxgo
   Bookmark.find(@params[:id]).destroy
   render :partial => "bookmarks"
  end  
  
  def toggle
    @document = Document.find(params[:id])

    if @document.update_attributes(:completed => params[:completed])
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
      p "yyyyyeeeeaaaahhhhh!"
    else
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
      p "ffffffffffffffffuuuuuuuuuuuuuuuuuuccccccccccccckkkkkkkkkkkkkk"
    end
  end
  
  def togssgle
    @document = Document.find(11) #params[:id])
    @document.description = "woot"
    @document.save

    # if it used only by AJAX call, you don't rly need for 'respond_to'
    render :nothing => true
  end
  
  def stoggle
    p "11111111111111111111"
    @document = Document.find(params[:id])
    @pages = Page.where("document_id = "+params[:id]).first
    p "22222222222222222222"
    if @pages.exclude then 
      @pages.exclude = false
    else
      @pages.exclude = true
    end
    p "33333333333333333333"
    if @pages.save then
      p "update successful"
    else
      p "update failed"
    end
      #render :nothing => true
  end
  
  def convert
    @pages = Page.where("document_id = "+params[:id]+" and (template_id IS NOT NULL or template_id <> '0')").order("number ASC")   
    @pages.each { |po|
      @template = Template.find(po.template_id)
      @sections = Section.where("template_id = #{@template.id}")
      
      gc = Magick::Draw.new
      
      p po.path
      p po.filename
      
      img1 = Magick::Image::read(po.path + po.filename) { 
      }.each { |img1, i| 

        # Picture Section
        width,height = img1.columns, img1.rows
        img2 = img1
        
        @sections.each  { |s|
          
          # make section directory
          directory_name = po.path.gsub("/img5/","/sections/")
          Dir.mkdir(directory_name) unless File.exists?(directory_name)
          
          
          # make section-page directories
          directory_name = directory_name + "#{po.number}/"
          Dir.mkdir(directory_name) unless File.exists?(directory_name)
          
          filePath = directory_name
          tessPath = filePath.gsub("/sections/#{po.number}/", "/tesseract/")
          fileName = po.filename.gsub(".png","") + "_#{s.id}.png"
          tessName = fileName.gsub(".png","")
          
          temp = img1.crop(s.xOrigin, s.yOrigin, s.width, s.height, true)
          temp.write(directory_name + fileName) { }
          
          # draw extracted areas
          gc.fill("RoyalBlue  ")
          gc.stroke_width(3)
          gc.stroke("NavyBlue")
          gc.rectangle(s.xOrigin, s.yOrigin, s.width+s.xOrigin, s.height+s.yOrigin)
          gc.draw(img2)

          # make tesseract directory
          Dir.mkdir(tessPath) unless File.exists?(tessPath)
          tessPath = tessPath + "#{po.number}/"
          Dir.mkdir(tessPath) unless File.exists?(tessPath)
          
          # generate tesseract command
          convertString = "tesseract " + filePath + fileName + " " + tessPath + tessName   
          
          # execute tesseract command
          system(convertString) 
          
          # Insert into Assets
          root = filePath.gsub("/assets/products/#{po.document_id}/original/#{fileName}","")
                   
          @asset = Asset.new
          @asset.page_id =  po.id
          @asset.section_id = s.id 
          @asset.path = filePath
          @asset.url = "/assets/products/#{po.document_id}/original/sections/#{po.number}/" 
          @asset.filename = fileName
          @asset.tpath = tessPath
          @asset.turl = "/assets/products/#{po.document_id}/original/tesseract/#{po.number}/" 
          @asset.tfilename = tessName + ".txt"
          @asset.language = 13
          @asset.value =  File.read(tessPath + tessName + ".txt").encode('UTF-16', :invalid => :replace, :replace => '').encode('UTF-8')[0..254].strip
          @asset.save
        }  
        
        # make preview directory
        imgPath = po.path.gsub("/img5/","/preview/")
        Dir.mkdir(imgPath) unless File.exists?(imgPath)
        imgPath = imgPath + "#{po.number}/"
        Dir.mkdir(imgPath) unless File.exists?(imgPath)
        
        # create full image
        img2.write(imgPath + po.filename.gsub(".png","") + "_#{@template.id}.png") { }     
        
        # create thumbnail
        thumbDirectory = po.path.gsub("/img5/","/thumb/")
        Dir.mkdir(thumbDirectory) unless File.exists?(thumbDirectory)
        thumb = img2.scale(200, 266)
        thumb.write(thumbDirectory + po.filename.gsub(".png","_thx.png") ) { }
            
        # create medium thumbnail 
        mediumDirectory = po.path.gsub("/img5/","/medium/")
        Dir.mkdir(mediumDirectory) unless File.exists?(mediumDirectory)
        #medium = img2.scale(200, 266)
        medium = img2.scale(300, 366)
        medium.write(mediumDirectory + po.filename.gsub(".png","_mdx.png") ) { }
            
        # create large thumbnail 
        largeDirectory = po.path.gsub("/img5/","/large/")
        Dir.mkdir(largeDirectory) unless File.exists?(largeDirectory)
        large = img2.scale(0.3)
        large.write(largeDirectory + po.filename.gsub(".png","_lgx.png") ) { }
      }
    }
    
    # export data
    export(params[:id])
  
    redirect_to "/data/"
  end
    
    
  def export(id)
    @pages = Page.where("document_id = "+params[:id]+" and (template_id IS NOT NULL or template_id <> '0')").order("number ASC")   
    @again = true
    @pages.each { |po|
      @template = Template.find(po.template_id)
      @sections = Section.where("template_id = #{@template.id}")
      @assets = Asset.where("page_id = #{po.id}").order("id ASC")
      
      line = ""
      @assets.each { |az|
        line = line + " \"" + az.value + "\", "
      }
      
      ln = line.length-3
      
      line = line[0..ln]

      csvDirectory = po.path.gsub("/img5/","/csv/")
      Dir.mkdir(csvDirectory) unless File.exists?(csvDirectory)
      
      @doc = Document.find(po.document_id)
      fn = File.basename("#{@doc.source.url}".split("?")[0],".pdf") + "-#{@template.name}.csv"
      
      somefile = File.open(csvDirectory + fn, "a")
      somefile.puts line
      
      @datum = Datum.where("template_id = #{@template.id} and page_id = #{po.id}")
      
      if (@datum.count < 1) and (@again) then
        @again = false
        
        @datum = Datum.new
        @datum.document_id = params[:id]
        @datum.template_id = @template.id
        @datum.page_id = po.id
        @datum.path = csvDirectory
        @datum.url = po.url.gsub("/img5/","/csv/")
        @datum.filename = fn
        @datum.description = Document.find(po.document_id).description
        @datum.save  
      end
      
      somefile.close
    }
     
  end
  
  
  def createDefaultSettings
    @setting = Setting.where(user_id: current_user.id).first
    if !@setting.present? then
      @setting = Setting.new
      @setting.user_id = current_user.id
      @setting.default_template = nil
      @setting.default_language = 13 
      @setting.default_notification = current_user.email  
      @setting.notify_complete = false
      @setting.trimLeft = 0
      @setting.trimRight = 0
      @setting.trimTop = 0
      @setting.trimBottom = 0
      @setting.save
    end
  end
  
  def separatePages(id)
    #
    # yep
    #
    @document = Document.find(id)
    
    createDefaultSettings()
    @setting = Setting.where(user_id: current_user.id).first
    
    trimLeft = @setting.trimLeft
    trimRight = @setting.trimRight
    trimTop = @setting.trimTop
    trimBottom = @setting.trimBottom
    
    readFileExtension = ".pdf"
    writeFileExtension = ".png"
    
    origionalFile = "#{@document.source.path}".split("?")[0]
    
    filePath = File.dirname("#{@document.source.path}")
    fileURL = File.dirname("#{@document.source.url}")
    fileName = File.basename("#{@document.source.url}".split("?")[0],readFileExtension)
    
    counter = "0000"
 
    # separate and align pages create thumbs for pages
    # add the aligned pages to list of document assets
    #img1 = Magick::Image::read(filePath + "/" + fileName + readFileExtension) { 
    img1 = Magick::Image::read(origionalFile) { 
      
      self.density = 300
      self.image_type = Magick::GrayscaleType
      
    }.each { |img1, i|  
      
      #
      #
      directory_name = filePath + "/" + "thumb"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      thumb = img1.scale(100, 133)
      thumb.write(filePath + "/thumb/" + fileName + "-%04d_th" + writeFileExtension) { }
      
      #
      #
      directory_name = filePath + "/" + "img1"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      img1.write(filePath + "/img1/" + fileName + "-%04d" + writeFileExtension) { }
      
      #
      #
      directory_name = filePath + "/" + "img2"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      img2 = img1.deskew("40%")   
      img2.write(filePath + "/img2/" + fileName + "-%04d" + writeFileExtension) { }
      
      # quantitize
      #
      #
      directory_name = filePath + "/" + "img3"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      img3 = img2.quantize(2, Magick::GRAYColorspace)
      img3.write(filePath + "/img3/" + fileName + "-%04d" + writeFileExtension) { }
      
      # metrics
      width = img3.columns
      height = img3.rows
      
      
      #make this variable
      #
      #
      directory_name = filePath + "/" + "img4"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      img4 = img3.crop(Magick::EastGravity,width-trimLeft,height)
      img4.fuzz = "5%"
      img4.write(filePath + "/img4/" + fileName + "-%04d" + writeFileExtension) { }
      
      
      #
      #
      directory_name = filePath + "/" + "img5"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      img5 = img4.trim(true)
      img5.write(filePath + "/img5/" + fileName + "-%04d" + writeFileExtension) { }
      
      #
      #
      directory_name = filePath + "/" + "medium"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      #medium = img5.scale(200, 266)
      medium = img5.scale(275, 366)
      medium.write(filePath + "/medium/" + fileName + "-%04d_md" + writeFileExtension) { }
      
      #
      #
      directory_name = filePath + "/" + "large"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      large = img5.scale(0.3)
      large.write(filePath + "/large/" + fileName + "-%04d_lg" + writeFileExtension) { }
      
      #
      #
      directory_name = filePath + "/" + "xlarge"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      xlarge = img5.scale(925,1230)
      xlarge.write(filePath + "/xlarge/" + fileName + "-%04d_xlg" + writeFileExtension) { }
      
      #new metrics
      wdth = img5.columns
      hght = img5.rows
      
      #p "-~-~^-"
      #imgX = img5.scale(wdth, 1)
      #imgY = img5.scale(1, hght)
      
      imgX1 = img5.scale(640, 1)
      imgY1 = img5.scale(1, 640)
          
      
      #
      #
      directory_name = filePath + "/" + "template"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      imgX1.write(filePath + "/template/" + fileName + "-%04d-imgX1" + writeFileExtension) { }
      imgY1.write(filePath + "/template/" + fileName + "-%04d-imgY1" + writeFileExtension) { }
      
      #imgX1.write(filePath + "/template/" + fileName + "-%02d-imgX1" + ".txt") { }
      #imgY1.write(filePath + "/template/" + fileName + "-%02d-imgY1" + ".txt") { }
      
      #create graph
      
      imgX2 = imgX1.scale(640, 1)
      imgY2 = imgY1.scale(1, 640)
      
      imgX2.write(filePath + "/template/" + fileName + "-%04d-imgX2" + writeFileExtension) { }
      imgY2.write(filePath + "/template/" + fileName + "-%04d-imgy2" + writeFileExtension) { }
      
      #imgX2.write(filePath + "/template/" + fileName + "-%02d-imgX2" + ".txt") { }
      #imgY2.write(filePath + "/template/" + fileName + "-%02d-imgY2" + ".txt") { }
      
      #create graph      
      #create hash
      #search hash
      #determine if template exists
      # set page template id below

      #log page
      @page = Page.new
      @page.document_id = id
      @page.user_id = current_user.id
      @page.number = counter
      @page.dpi = 300
      @page.height = hght
      @page.width = wdth
      @page.top = trimTop
      @page.bottom = trimBottom
      @page.left = trimLeft
      @page.right = trimRight
      @page.filename = fileName + "-#{counter}" + writeFileExtension
      @page.path = filePath + "/img5/"
      @page.url = fileURL + "/img5/"
      @page.exclude = false
      @page.public = false
      @page.save

      #next counter
      counter = counter.next
    }
  end
  
  def findTemplate
    
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end
    
    def create_directory_if_not_exists(directory_name)
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:user_id, :description, :source)
    end
end

