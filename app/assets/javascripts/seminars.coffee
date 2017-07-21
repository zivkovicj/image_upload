# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



ready = ->
    if $('.btn-info').length > 0
        $("#dialog1").dialog
            autoOpen: false
            width: 520
            buttons : 
                Ok: ->
                    $(this).dialog("close")
        
        $('#btn-info1').on "click", ->
            $("#dialog1").dialog("open")
            
        $("#dialog2").dialog
            autoOpen: false
            width: 520
            buttons : 
                Ok: ->
                    $(this).dialog("close")
        
        $('#btn-info2').on "click", ->
            $("#dialog2").dialog("open")    
            
            
    if $('#add-more-button').length > 0
        timesClicked = 1
        $('#add-more-button').on "click", ->
            $(".click-" + timesClicked).fadeIn()
            timesClicked = timesClicked + 1
            if timesClicked == 4
                $('#add-more-button').fadeOut()
            
    if $('.teachReqOption').length > 0
        $('.teachReqOption').on "click", ->
            $('.teachReqOption').removeClass("highSingOpt").addClass("lowSingOpt")
            $(this).addClass("highSingOpt")
            reqId = $(this).attr('reqId')
            aulaId = $(this).attr('aulaId')
            url = '/aulas/'+aulaId
            $.ajax
                type: "PUT",
                url: url,
                dataType: "json"
                data:
                    aula:
                        teachRequest: reqId
                    
    if $('.learnReqOption').length > 0
        $('.learnReqOption').on "click", ->
            $('.learnReqOption').removeClass("highSingOpt").addClass("lowSingOpt")
            $(this).addClass("highSingOpt")
            reqId = $(this).attr('reqId')
            aulaId = $(this).attr('aulaId')
            url = '/aulas/'+aulaId
            $.ajax
                type: "PUT",
                url: url,
                dataType: "json"
                data:
                    aula:
                        learnRequest: reqId
                    
    if $('.prefReqOption').length > 0
        $('.prefReqOption').on "click", ->
            $('.prefReqOption').removeClass("highSingOpt").addClass("lowSingOpt")
            $(this).addClass("highSingOpt")
            reqId = $(this).attr('reqId')
            aulaId = $(this).attr('aulaId')
            url = '/aulas/'+aulaId
            $.ajax
                type: "PUT",
                url: url,
                dataType: "json"
                data:
                    aula:
                        prefRequest: reqId
    
    if $('.tyrion').length > 0
        $('.seatButt').prop("disabled",true)
        currSeating = $('.tyrion').val().split(" ")
        currNeed = $('.jaime').val().split(" ")
        $('.tyrion').val(currSeating)
        $('.jaime').val(currNeed)
        
        $('.draggable-item').draggable
            stack: '.droppable-item'
            stack: '.draggable-item'
            start: (event, ui) ->
                if $(this).parent().attr("id") == "orphans"
                    orphanIndex = currNeed.indexOf($(this).attr("id"))
                    currNeed.splice(orphanIndex,1)
                    $('.jaime').val(currNeed)
                    
                else
                    seat = $(this).closest(".seat").attr("id")-1000;
                    currSeating[seat] = 0
                    $('.tyrion').val(currSeating)
                
                    
        $('.droppable-item').droppable
            over: (event, ui) ->
                $(this).addClass("my-placeholder")
            drop: (event, ui) ->
                $(this).removeClass("my-placeholder")
                if ($(this).children().length) > 0
                    oldStudent = $(this).children().first()
                    $("#dashOutline").hide()
                    oldStudent.detach().addClass("block").appendTo(".orphans")
                    currNeed.push(oldStudent.attr("id"))
                    $('.jaime').val(currNeed)
                justdragged = $(ui.draggable) 
                kid = justdragged.attr("id")
                seat = $(this).attr("id")-1000
                currSeating[seat] = kid
                $('.tyrion').val(currSeating)
                justdragged.removeClass("block")
                $(this).append(justdragged.removeAttr('style'))
                if ($('#orphans').children().size()) == 1
                    $("#dashOutline").show()
                $('.seatButt').prop("disabled",false)
            out: (event, ui) ->
                $(this).removeClass("my-placeholder")
            
                
        $('.supernaut').droppable
            drop: (event, ui) ->
                $("#dashOutline").hide()
                justdragged = $(ui.draggable)
                kid = justdragged.attr("id")
                currNeed.push(kid)
                $('.jaime').val(currNeed)
                justdragged.removeAttr('style').detach().addClass("block").appendTo(".orphans")
                $('.seatButt').prop("disabled",false)
    
    $('#toggle_text').on "click", ->
        if $('.themScores').hasClass("currently_hidden")
            $('.themScores').fadeIn()
            $('.themScores').removeClass("currently_hidden")
            $(this).text($(this).attr("first_text"))
        else
            $('.themScores').fadeOut()
            $('.themScores').addClass("currently_hidden")
            $(this).text($(this).attr("second_text"))
   
   
    if $('.clickySeat').length > 0
        $('.clickySeat').on "click", ->
            goobergonk = $(this).find(".presentTag")
            aulaId = $(this).attr('id')
            url = '/aulas/'+aulaId
            if goobergonk.text() == "Absent"
                attendance = true
                $(this).removeClass("absent")
                goobergonk.text("Present")
            else
                attendance = false
                $(this).addClass("absent")
                goobergonk.text("Absent")
            $.ajax
                type: "PUT",
                url: url,
                dataType: "json"
                data:
                    aula:
                        present: attendance
            
    
    if $('#scoreTable').length > 0
        $('.steelPanther').on "click", ->
            $('#scoreTable tr td').removeClass('highlighted')
            $('#scoreTable tr th').removeClass('highlighted')
            $(this).closest('tr').find('td,th').addClass('highlighted')
            col = $(this).index()+1
            $('#scoreTable').find('tr :nth-child('+col+')').addClass('highlighted');
    
    if $('#dialog5').length > 0
        console.log("Scoober Dee")
        unpressed = true
        $("#dialog5").dialog
            autoOpen: false
            width: 520
            buttons : 
                Ok: ->
                    $(this).dialog("close")
                    
        $('.boulderfist').on "click", (event) ->
            if unpressed and $(this).prop("checked") == true
                $("#dialog5").dialog("open")
                
    if $('.select_box').length > 0
        $('.select_box').on "change", (event) ->
            points_poss = 0
            $(".left_box").each (index, element) =>
                a = $(element).val()
                partner_num = $(element).attr('partner')
                b = $("#syl_"+partner_num+"_point_value").val()
                points_poss += a * b
        
            $('#total_disp').text(points_poss)
    
            
$(document).on('turbolinks:load', ready)
