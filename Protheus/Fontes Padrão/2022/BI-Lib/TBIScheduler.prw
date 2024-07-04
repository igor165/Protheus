// ######################################################################################
// Projeto: BI Library
// Fonte  : TBIScheduler.prw
// ---------+---------------------------+------------------------------------------------
// Data     | Autor                     | Descricao
// ---------+---------------------------+------------------------------------------------
// 15.10.04 | 0739 Aline Correa do Vale |
// 27.11.07 | 2516 Lucio Pelinson       |
// 08.06.09 | 3510 Gilmar P. Santos     | FNC: 00000012280/2009
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "TBIScheduler.ch"

/*--------------------------------------------------------------------------------------
@class TBIScheduler
@entity Mensagem
Envio de Mensagens e avisos do sistemas.
@table TBIScheduler
--------------------------------------------------------------------------------------*/
class TBIScheduler from TBITable

	data foFileLock
	data foFileKey
	data fcFileCtrl

	method New(cTableName, cAlias, cInstancia) constructor
	method NewBIScheduler(cTableName, cAlias)
	method lSetExecution()
	method lOpen()
	method cClassName()
	method Stop()
	method Start()
	method isRunning()
	method recalcDateFire() 

endclass

method New(cTableName, cAlias, cInstancia) class TBIScheduler
	::NewBIScheduler(cTableName, cAlias, cInstancia)
return

method NewBIScheduler(cTableName, cAlias, cInstancia) class TBIScheduler
	// Table
	::NewTable(cTableName, cAlias)
	::cEntity()
	//cria arquivos de controle de execução
	::fcFileCtrl := alltrim(if(!empty(cInstancia),cInstancia,"BSC"))
	::foFileKey  := TBIFileIO():new("KEY"+::fcFileCtrl+".SCH")
	::foFileLock := TBIFileIO():new("RUN"+::fcFileCtrl+".SCH")

	// Fields 
	::addField(TBIField():New("ID"			,"C"	,010))  //id
	::addField(TBIField():New("NOME"		,"C"	,060)) 	//nome do agendamento
	::addField(TBIField():New("DATAINI"		,"D"	,8))   	//data inicial válida
	::addField(TBIField():New("HORAINI"		,"C"	,5))   	//hora inicial válida
	::addField(TBIField():New("DATAFIM"		,"D"	,8))   	//data final válida
	::addField(TBIField():New("HORAFIM"		,"C"	,5))   	//hora final válida
	::addField(TBIField():New("FREQ"		,"N"	  ))	//frequencia: 1-Diário 2-Semanal 3-Mensal
	::addField(TBIField():New("DIAFIRE"		,"N"	  ))	//dia do mês ou semana que será executado
	::addField(TBIField():New("HORAFIRE"	,"C"	,5))   	//horário que será executado
	::addField(TBIField():New("ATIVO"		,"C"	,1))
	::addField(TBIField():New("DATAEXE"		,"D"	,8))	//data da última execução
	::addField(TBIField():New("HORAEXE"		,"C"	,5))    //horário da última execução
	::addField(TBIField():New("DATANEXT"	,"D"	,8))	//data da próxima execução
	::addField(TBIField():New("HORANEXT"	,"C"	,5))	//horário da próxima execução
	::addField(TBIField():New("ACAO"		,"C"	,120))	//acao a ser executada neste agendamento
	::addField(TBIField():New("ENV"			,"C"	,50))	//Enviroment da execucao
	
	// Indexes
	::addIndex(TBIIndex():New(cTableName+"Y",	{"ID", "NOME"}, .t.))
	::addIndex(TBIIndex():New(cTableName+"Z",	{"DATAINI", "HORAINI"}, .f.))

return

method lOpen() class TBIScheduler
	abstract
return

method cClassName() class TBIScheduler
	abstract
return

method Stop() class TBIScheduler
	if(!::foFileLock:lErase()) //está em execução
		::foFileKey:lErase()
		conout(STR0001) //"Scheduler finalizado!"
	endif
return

method isRunning() class TBIScheduler
	//se conseguir apagar o arquivo, é pqe não esta em execução
	::foFileLock:lErase()
return (::foFileLock:lExists())

// Execute
method Start() class TBIScheduler
	local aParams := {}

	aAdd(aParams, ::cClassName())

	if(::foFileLock:lExists() .and. !::foFileLock:lErase())
		conout(" ")
		conout(STR0002) //"O Scheduler nao pode ser Inicializado, pois o mesmo já esta em execução!"
	else
		if(!::foFileKey:lCreate(FC_NORMAL))
			conout(" ")
			ExUserException(STR0003) //"O Scheduler nao pode ser Inicializado, verifique os atributos de gravaçao"
		else
			::foFileKey:lClose()
			aAdd(aParams, ::fcFileCtrl)
		                     
			// Executando JOB
			conout(STR0004) //"Iniciando o Scheduler ..."
			StartJob("Scheduler", GetEnvServer(), .f., aParams)
		endif
	endif

return   


method lSetExecution() class TBIScheduler
	local lRetorno 	:= .f.
	local dNextFire	:= nil 
	local dIni		:= nil
	local aFields 	:= {}


    dIni := ::dValue("DATANEXT")
	if !empty(dIni)
		dIni := dIni + 1
	endif
	dNextFire := buildNextFire(	::nValue("FREQ"),; 
								::cValue("HORAFIRE"),;  
								dIni,;  
								::nValue("DIAFIRE"),;
								::cValue("HORAFIM"),;  
								::dValue("DATAFIM") )  
	
	         
	if dNextFire == nil
		aAdd( aFields, {"DATANEXT", space(8)} )
		aAdd( aFields, {"HORANEXT", space(5)} )
	else
		aAdd( aFields, {"DATANEXT", dNextFire} )
		aAdd( aFields, {"HORANEXT", ::cValue("HORAFIRE")} )
	endif
	
	aAdd( aFields, {"DATAEXE", date()} )
	aAdd( aFields, {"HORAEXE", time()} )
	
	if(::lUpdate(aFields))
		lRetorno := .T.
	endif


return lRetorno


//Recalcula a data da proxima execução
method recalcDateFire() class TBIScheduler    
	local dNextFire := nil
	local aFields 	:= {	{"HORANEXT", ""},; 
							{"DATANEXT", ""}};
							  
	::_First()
	while(!::lEof())
		if !(alltrim(::cValue("ID")) == "0")

			//conout("Recalculando " + alltrim(::cValue("NOME")) + " ..." )   
			
			dNextFire := buildNextFire(	::nValue("FREQ"),; 
										::cValue("HORAFIRE"),;  
										::dValue("DATANEXT"),;  
										::nValue("DIAFIRE"),;
										::cValue("HORAFIM"),;  
										::dValue("DATAFIM") )  
			
			         
			if dNextFire == nil
		   		aFields[1][2] := space(5)
		   		aFields[2][2] := space(8) 
			else
		   		aFields[1][2] := ::cValue("HORAFIRE")
		   		aFields[2][2] := dNextFire
			endif
			
				
		   	if !(::lUpdate(aFields))
		   		conout(STR0005) //"Erro ao recalcular Scheduler!"		
		   	endif
		endif
		::_Next()
	enddo 
//	conout("Scheduler Recalculado ...")                  
return    

// Funcao executa o job
function Scheduler(aParams)
	local oScheduler, i, nAt, nInd, cHorario, j
	local oFileKey 	:= TBIFileIO():New("KEY"+aParams[len(aParams)]+".SCH")
	local oFileRun 	:= TBIFileIO():New("RUN"+aParams[len(aParams)]+".SCH")
	local aJobParam	:= {}
	local aFields 	:= {} 
	local aNewReg 	:= {}
	local aPath 	:= {}
	local cPath		:= ""
	local cAcao 	:= ""
	local lFirst		:= .T. //Indica se os agendamentos precisam ser recalculados.	
	local aThreads := GetUserInfoArray()
	local nCnt := 1
	local lExecutando := .F.
	local nNumThreads := 0
	
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on
	
	if((oFileRun:lExists() .and. !oFileRun:lErase()) .or. !oFileRun:lCreate(FC_NORMAL+FO_EXCLUSIVE))
		conout(STR0006) //"Scheduler ja em execução!"
		return
	endif
	
	oScheduler := &(aParams[1]+"():New()") //parametro do ::cClassName()
	
	//--------------------------------------------------------   
	// Atualiza a tabela de agendamentos. 
	//--------------------------------------------------------			
	if(oScheduler:lOpen())
		lFirst := .T.
	
		//--------------------------------------------------------   
		// Atualiza a tabela de agendamentos. 
		//-------------------------------------------------------- 	 
				
		oScheduler:fcTablename := oScheduler:fcAlias := alias()	
		oScheduler:SetOrder(2)
		
		while (oFileKey:lExists() .and. !killapp() )
			
			//--------------------------------------------------------   
			// Recalcula os agendamentos na primera carga do schelduler. 
			//-------------------------------------------------------- 	                           
			If ( lFirst )  
	 			oScheduler:recalcDateFire()
			Else
  				lFirst := .F.					
			EndIf              
		
			oScheduler:_First()
			while(!oScheduler:lEof())
				if 	oScheduler:dValue("DATANEXT") == date() .and. ;
					nHourToMinute(oScheduler:cValue("HORAFIRE")) <= nHourToMinute(time())
					
					cAcao := alltrim(oScheduler:cValue("ACAO"))
					aJobParam := aBIToken(cAcao,",")
					if(at("(",cAcao)>0 .and. len(aJobParam)>0)
						nAt := at("(",cAcao)
						cAcao := subs(cAcao,1,nAt-1)
						aJobParam[1] := subs(aJobParam[1],nAt+1,len(aJobParam[1])-nAt)
						nAt:=at(")",aJobParam[len(aJobParam)])
						if(nAt>0)
							aJobParam[len(aJobParam)] := subs(aJobParam[len(aJobParam)],1,nAt-1)
						endif
					endif
					for i:=1 to len(aJobParam)
						aJobParam[i] := &(aJobParam[i])
						cPath := aJobParam[i]
						if(valtype(cPath)=="C" .and. at("\\",cPath)>0) //compatibilizacao com todos os bancos
							aPath:= aBIToken(cPath,"\")
							cPath := "\"
							for j:= 1 to len(aPath)
								cPath += if(!empty(aPath[j]),aPath[j]+"\","")
							next
						endif
						aJobParam[i] := cPath
					next
					cHorario := subs(time(),1,5)
					cHorario := if(subs(cHorario,1,1)='0',subs(cHorario,2,4)+" ",cHorario)
					conout("")
					BIConOut(STR0007) //"Scheduler - Em execução:"
					BIConOut(STR0008 + alltrim(oScheduler:cValue("NOME"))) //"Agendamento: "
					BIConOut(STR0009 + cAcao) //"Ação: "
					conout("")
					oScheduler:lSetExecution()
	
					
					StartJob(cAcao, alltrim(oScheduler:cValue("ENV")), .f., aJobParam)
				endif
				oScheduler:_Next()
			enddo
			sleep(40000)
		enddo
	endif
	
	oFileRun:lClose()
return

//cHora (00:00)
function nHourToMinute(cHora)
	local nAt			:= at(':',cHora)
	local nHoras		:= val(subs(cHora,1,nAt-1))*60
	local nMinutos		:= val(subs(cHora,nAt+1,2))
return nHoras+nMinutos  

//Calcula a data da proxima execução
function buildNextFire(nFreq, hIni, dIni, nDiaFire, hFim, dFim)
	local dRet	:= nil
	local dRef	:= nil 
    
    //Veririfica se exisite uma data
	if !empty(dIni)

		//Calcula a data de Referencia	
		if dIni <= date()
			dRef := date()
			if nHourToMinute(time()) > nHourToMinute(hIni)
				dRef += 1
			endif
		else              
			dRef := dIni
		endif
	
		do case 
			case nFreq == 1 //Diario
				dRet := dRef
			case nFreq == 2 //Semanal
				while dow(dRef) <> nDiaFire
					dRef += 1	
				end while
				dRet := dRef
			case nFreq == 3 //Mensal
				while day(dRef) <> nDiaFire
					dRef += 1	
				end while
				dRet := dRef
		end case          
		
		//Verifica se esta dentro do período de execução
		if dRet > dFim 
			dRet := nil	
		elseif dRet = dFim 
			if nHourToMinute(time()) > nHourToMinute(hFim)
				dRet := nil	
			endif
		endif
	endif
	
return dRet
