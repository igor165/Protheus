#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE  ___cPLSLog "BA1|BTS"
#DEFINE  ___cPLSNLg "BX4|BA0|BIM|BIA|BIF|BIJ|BJA|BJS|BCN|BMP|BMB|BMC|BH0"

STATIC lPLSA174	:= allTrim(funName()) == 'PLSA174'

/*/{Protheus.doc} PLUPTENC
Rotina generica para atualizar enchoice 
@type function
@author PLSTEAM
@since 04.07.2000
@version 1.0
/*/
function PLUPTENC(cAlias,nOpc,lLock,lforce,aCmpAlt)
local _nH		:= 0
local nInd		:= 0
local nPos     	:= 0
local cCodOpe   := ""
local cMemoria  := ""
local cCampo    := ""
local cVarErro 	:= ""       
local cCampoFil	:= ""
local cOldArea 	:= alias()         
local aStruc    := {}
local bVldOpeGrv:= {|| .f. }
local lLogGrv	:= .f.
local lLogGrvVld:= .t.
local cUsuari   := upper(PLRETOPE())
local cEstTrb   := getComputerName()
local cRotina 	:= funName()

default lLock 	:= .t.
default lforce 	:= .f.
default aCmpAlt := {}

// quando o alias for BX4, pode ser que seja o primeiro usuario que esta sendo incluindo
// neste caso nao pode chamar a PLSINTPAD porque nao vai encontrar nenhuma operadora padrao 
if  cAlias $ ___cPLSNLg
    cCodOpe  := "    " 
else
    cCodOpe  := PLSINTPAD()
endIf    

//Abre a area																 
dbSelectArea(cAlias)
aStruc := dbStruct()

if ( nPos := aScan(aStruc,{ |x|  at('_FILIAL',upper(x[1]) ) > 0 } ) ) > 0
	cCampoFil := aStruc[nPos,1]
else
	msgStop("Tabela [" + cAlias + "] sem o campo FILIAL, contacte o desenvolvimento.")
	return .f.
endIf

if nOpc == K_Alterar .and. ! PLSAltEnc(cAlias, @aStruc, @nPos, @cVarErro)
	
	if ! empty(cVarErro)
		msgStop(cVarErro)
	endIf
	
	return .f.
		
endIf   

//Testa integridade dos parametros recebidos...                            
if empty(cAlias) .or. empty(nOpc)
   msgStop("Nao conformidade na passagem de parametro para PLUPTENC()"+CHR(13)+" Alias "+cAlias)
   return .f.                           
endIf   

//Se for inclusao sempre lLock                                             
if nOpc == K_Incluir
   lLock := .t.
endIf 

//Inicia a transacao...                                                    
begin transaction

//Bloqueio o registro...                                                   
if lLock .and. nOpc <> K_Excluir
   recLock(cAlias,nOpc == K_Incluir)
endIf   

//Se nao for exclusao atualizo dados...                                    
if nOpc == K_Incluir

       bVldOpeGrv := { || BIQ->BIQ_INCLUI == "1" }

elseIf nOpc == K_Alterar   

       bVldOpeGrv := { || BIQ->BIQ_ALTERA == "1" }   

elseIf nOpc == K_Excluir

       bVldOpeGrv := { || BIQ->BIQ_EXCLUS == "1" }   

endIf        

BIQ->(dbSetOrder(1))
lLogGrv := ( cAlias $ ___cPLSLog ) .or. ( BIQ->(msSeek(xFilial("BIQ") + cCodOpe + cAlias)) .and. eval(bVldOpeGrv) )

if lLogGrv

   _nH  := PLSAbreSem("PLUPTENC.SMF")

   cSeq := PLBX1NEW()
   
   //Log de Inclusao ou Alteracao...                                          
   BX1->(recLock("BX1",.t.))
   
	   BX1->BX1_FILIAL   := xFilial("BX1")
	   BX1->BX1_SEQUEN   := cSeq
	   BX1->BX1_ALIAS    := cAlias
	   BX1->BX1_recno    := strZero(recno(),len(BX1->BX1_recno))
	   
	   if nOpc == K_Incluir
			BX1->BX1_TIPO     := "I"
	   elseIf nOpc == K_Alterar
			BX1->BX1_TIPO     := "A"
	   elseIf nOpc == K_Excluir
			BX1->BX1_TIPO     := "E"
	   endIf
	                                      
	   BX1->BX1_DATA     := date()
	   BX1->BX1_HORA     := time()
	   BX1->BX1_USUARI   := cUsuari
	   BX1->BX1_ESTTRB   := cEstTrb
	   BX1->BX1_ROTINA   := cRotina
	   
   BX1->(msUnLock())

   PLSFechaSem(_nH,"PLUPTENC.SMF")
   
endIf

if nOpc <> K_Excluir
	
	//Grava filial do sistema...
	&cCampoFil := xFilial(cAlias)
	
	//Gravo todos os campos a partir da filial que ja foi gravada...
	for nInd := 1 to len(aStruc)
		
		if nInd == nPos
			loop
		endIf
		
		//Monta os M->??? da vida e testa se eles existem. caso existam atualizo...
		cMemoria := "M->"+allTrim(aStruc[nInd,1])
		cCampo   := cAlias+"->"+allTrim(aStruc[nInd,1])
		
		if valType(&cMemoria) <> "U"
			
			cType01 := valType(&cCampo)
			cType02 := valType(&cMemoria)
			
			if cType01 <> cType02
				cVarErro := "Nao conformidade PLSGRV Campo "+cCampo
			else
				
				//Log de Alteracao...
				lLogGrvVld:= .t.
				aadd(aCmpAlt,substr(cCampo,At(">",cCampo)+1,len(cCampo)))
				if lLogGrv
					
					if (&cCampo <> &cMemoria) .and. nOpc == K_Alterar
						
						if cType01 == "C" .and. allTrim(&cCampo) == allTrim(&cMemoria)
							lLogGrvVld := .f.
						endIf
						
						if lLogGrvVld
							
							BX2->(recLock("BX2",.t.))
							
							BX2->BX2_FILIAL   := xFilial("BX2")
							BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
							BX2->BX2_CAMPO    := allTrim(aStruc[nInd,1])
							BX2->BX2_TITULO   := Posicione("SX3",2,allTrim(aStruc[nInd,1]),"X3_TITULO")
							
							if cType01 == "C"
								BX2->BX2_ANTval   := &cCampo
								BX2->BX2_NOVval   := &cMemoria
							elseIf cType01 == "N"
								BX2->BX2_ANTval   := str(&cCampo,17,4)
								BX2->BX2_NOVval   := str(&cMemoria,17,4)
							elseIf cType01 == "D"
								BX2->BX2_ANTval   := dtoc(&cCampo)
								BX2->BX2_NOVval   := dtoc(&cMemoria)
							endIf
							
							BX2->(msUnLock())
							
						endIf						
					endIf
					
				endIf
				
				//Gravo fisicamente...
				if nOpc == K_Alterar .or. nOpc == K_Incluir
					&cCampo := &cMemoria
				endIf
				
			endIf
			
		else
			cVarErro := "Nao conformidade PLSGRV Campo " + cCampo
		endIf
		
		if ! empty(cVarErro)
			exit
		endIf	
			
	next
	
//Campos atualizados. agora libero Lock do registro...
else
	
	//No caso de exclusao exluo o registro...
	dbSelectArea(cAlias)
	
	if recLock(cAlias,.f.)
		dbDelete()
		msUnLock()
	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSGRV - Nao foi possivel excluir o registro "+str(recno())+" do arquivo "+cAlias, 0, 0, {})
	endIf
	
endIf   

//Libera bloqueio ao registro...                                           
if lLock .and. nOpc <> K_Excluir
	msUnLock()
endIf

//No caso de inclusao atualiza GETSX8NUM()...                              
if nOpc == K_Incluir
   confirmSX8()
endIf   

//Finaliza a transacao...                                                 
end transaction

if ! empty(cVarErro)
	msgStop(cVarErro)
endIf

//Restauro area antiga...                                                  
if ! empty(cOldArea)
   dbSelectArea(cOldArea)
endIf   

return .t.

/*/{Protheus.doc} PLUPTCOLS
Atualizacao de dados da GetDados  
@type function
@author PLSTEAM
@since 04.07.2000
@version 1.0
/*/
function PLUPTCOLS(cAlias, aCols, aHeader, aVetTrab, nOpc, aChave, lObrig, lSUS, aArraySUS, aRecAlt, lIntSld)
local cOldArea 	:= alias()
local nCont    	:= 1
local nChave   	:= 1
local nFields  	:= 1
local lFlag		:= .f.
local cCampo	:= ""
local aCpoObri	:= {}
local nPosicao	:= 0
local nInd		:= 0
local aAreaSX3 	:= SX3->(getArea(,"SX3"))
local _nH		:= 0
local cCodOpe	:= ""
local bVldOpeGrv:= ""
local lLogGrv	:= .f.
local lRecAlt	:= .t.
local nPos      := 0
local nRecno    := 0
local cUsuari   := upper(PLRETOPE())
local cEstTrb   := getComputerName()
local cRotina 	:= funName()
local lpl500GML := isInCallstack("PLSA500GML")

default aChave 		:= {}
default lObrig 		:= .f.
default aVetTrab 	:= {}
default lSUS 		:= .f.
default aArraySUS	:= {}
default aRecAlt		:= {{"","",0,0}}
default lIntSld	:= .f.

// quando o alias for BX4, pode ser que seja o primeiro usuario que esta sendo incluindo
// neste caso nao pode chamar a PLSINTPAD porque nao vai encontrar nenhuma operadora padrao
if  cAlias $ ___cPLSNLg
	cCodOpe  := "    "
else
	cCodOpe  := PLSINTPAD()
endIf

//Trata nOpc...
if nOpc <> K_Incluir .and. nOpc <> K_Alterar .and. nOpc <> K_Excluir
	return
endIf

lRecAlt := len(aRecAlt) > 0 .and. ! empty(aRecAlt[1,1])

//Inicia transacao...
begin transaction
	
	//Se nao for exclusao atualizo dados...
	if nOpc == K_Incluir
		
		bVldOpeGrv := { || BIQ->BIQ_INCLUI == "1" }
	
	elseIf nOpc == K_Alterar
	
		bVldOpeGrv := { || BIQ->BIQ_ALTERA == "1" }
	
	elseIf nOpc == K_Excluir
	
		bVldOpeGrv := { || BIQ->BIQ_EXCLUS == "1" }
	
	endIf
	
	BIQ->(dbSetOrder(1))
	lLogGrv := ( cAlias $ ___cPLSLog ) .or. ( BIQ->(msSeek(xFilial("BIQ")+cCodOpe+cAlias)) .and. eval(bVldOpeGrv) )
	
	aCpoObri := {}
	
	if lObrig
		
		SX3->(dbSetOrder(2))
		
		for nInd := 1 to len(aHeader)
		
			if SX3->(msSeek(allTrim(aHeader[nInd,2])))
		
				if SX3->X3_CONTEXT <> "V"
				
					if X3Obrigat(SX3->X3_CAMPO) 
						aadd(aCpoObri,allTrim(aHeader[nInd,2]))
					endIf
					
				endIf
				
			endIf
			
		next
		
	endIf
	
	//Trata aVetTrab...
	if valType(aVetTrab) <> "A" .or. len(aVetTrab) == 0
		aVetTrab := {0}
	endIf
	
	//Seleciono area padrao...
	dbSelectArea(cAlias)
	
	if nOpc == K_Incluir
	
		for nCont := 1 to len(aCols)
		
			// caso tenha sido passado o parametro lObrig == .t. e tenha algum campo obrigatorio nao preenchido nao sera gravado o registro no arquivo.
			lFlag := .f.
			
			for nInd := 1 to len(aCpoObri)
			
				cCampo   := allTrim(aCpoObri[nInd])
				nPosicao := gdFieldPos(cCampo,aHeader)
			
				if ( empty(aCols[nCont,nPosicao]) ) .and. ( valType(aVetTrab) == "A" .and. len(aVetTrab) >= nCont .and. aVetTrab[nCont] == 0 )
					lFlag := .t.
				endIf
				
			next
			
			if   ! aCols[nCont,len(aHeader)+1] .and. !lFlag
				
				recLock(cAlias,.t.)
					
					//correcao na gravacao da filial - daher
					cCpoFil  := fieldName(1)
					
					if cCpoFil <> cAlias + "_FILIAL"
						
						//se a tabela tem FILIAL ..
						if ( nPos := (cAlias)->( fieldPos( cAlias + "_FILIAL" ) ) ) > 0 
					
							cCpoFil  := fieldName(nPos)
							&cCpoFil := xFilial(cAlias)
					
						else
					
							FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Tabela ["+cAlias+"] sem o campo " + cAlias + "_FILIAL, contacte o desenvolvimento.", 0, 0, {})
					
						endIf
					
					else
						&cCpoFil := xFilial(cAlias)
					endIf
					
					for nChave  := 1 to len(aChave)
					
						cField  := aChave[nChave,1]
						cValUpt := aChave[nChave,2]
					
						if cField == "BD6_DATPRO" .and. lSUS .and. (cValUpt != BD5->BD5_DATPRO)
							&cField := BD5->BD5_DATPRO
						else
							&cField := cValUpt
						endIf
						
					next
					
					for nFields := 1 to len(aHeader)
					
						if aHeader[nFields,10] <> "V"
					
							cField  := allTrim(aHeader[nFields,2])
							cValUpt := aCols[nCont,nFields]

							&cField := cValUpt
							
							//ATENÇÃO - Ajuste para gravar no campo SALDO quando for clone de Sol. Internação. Não remova! 
							if lIntSld .and. cField == "BE2_QTDPRO"
								&("BE2_SALDO") := cValUpt
							endif
								
							//Ressarcimento SUS
							if cField == "BD6_QTDPRO" .and. lSUS 
								
								if aArraySUS != nil .and. len(aArraySUS) > 0
									
									//BD6_SLVPAD
									if aArraySUS[nCont][50][1] == "SLVPAD"
										
										cField 	:= "BD6_" + aArraySUS[nCont][50][1]
										&cField := aArraySUS[nCont][50][2]
										
									endIf
									
									//BD6_SLVPRO
									if aArraySUS[nCont][51][1] == "SLVPRO"
									
										cField 	:= "BD6_" + aArraySUS[nCont][51][1]
										&cField := aArraySUS[nCont][51][2]
										
									endIf
									
									//BD6_SLVDES
									if aArraySUS[nCont][52][1] == "SLVDES"
										cField  := "BD6_" + aArraySUS[nCont][52][1]
										&cField := aArraySUS[nCont][52][2]
									endIf
									
								endIf
								
							endIf
							
								
						endIf
						
					next
					
				msUnLock()
				
				//Tem que ser aqui para pegar o recno correto Alexander 06/04/06
				if lLogGrv
				
					_nH  := PLSAbreSem("PLUPTCOL.SMF")
					
					cSeq := PLBX1NEW()
					
					//Log de Inclusao ou Alteracao...
					BX1->(recLock("BX1",.t.))
					
						BX1->BX1_FILIAL   := xFilial("BX1")
						BX1->BX1_SEQUEN   := cSeq
						BX1->BX1_ALIAS    := cAlias
						BX1->BX1_recno    := strZero(recno(),len(BX1->BX1_recno))
						BX1->BX1_TIPO     := "I"
						BX1->BX1_DATA     := date()
						BX1->BX1_HORA     := time()
						BX1->BX1_USUARI   := cUsuari
						BX1->BX1_ESTTRB   := cEstTrb
						BX1->BX1_ROTINA   := cRotina

					BX1->(msUnLock())
					
					PLSFechaSem(_nH,"PLUPTCOL.SMF")
				endIf
				
			endIf
		next
		
	elseIf nOpc == K_Alterar
		
		BDK->(dbSetOrder(1))//BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG
		BA1->(dbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		
		for nCont := 1 to len(aCols)
		
			if nCont > len(aVetTrab)
				nRecno := 0
			else
				nRecno := aVetTrab[nCont]
			endIf
			
			if ! aCols[ nCont, len(aHeader) + 1 ] 	
				
				if lRecAlt .and. aScan(aRecAlt, {|x| x[3] == nRecno } ) == 0
					loop
				endIf
				
			endIf		

			// caso tenha sido passado o parametro lObrig == .t. e tenha algum campo obrigatorio nao preenchido nao sera gravado o registro no arquivo.
			// O tratamento !(lpl500GML ) é devido a rotina inclusão de glosa mnaual temos clientes que criam campos na Tabela BDX customizados, na rotina de inclusão  de glosa manual
			// não é preenchido os campos da BDX customizados  e os registros das glosas não sao incluidos.
			// esse tratamento !(lpl500GML  ) se dá como necessario pois não estava gravando os itens de glosa.
			lFlag := .f.
			
			if ! aCols[ nCont, len(aHeader) + 1 ] 
				
				for nInd := 1 to len(aCpoObri)
				
					cCampo   := allTrim(aCpoObri[nInd])
					nPosicao := gdFieldPos(cCampo,aHeader)
					
					if ( empty(aCols[nCont,nPosicao])) .and. ( valType(aVetTrab) == "A" .and. len(aVetTrab) >= nCont .and. aVetTrab[nCont] == 0 )  .and. !lpl500GML
						lFlag := .t.
					endIf
					
				next
				
			endIf	
			
			if ! aCols[ nCont, len(aHeader) + 1 ] .and. ! lFlag .and. valType(nRecno) == "N"
			
				// vou verificar se existe alguma BDK para o usuário, pois se não houver devo limpar os campoas BA1_FAICOB e BA1_MUDFAI
				if cAlias == "BDK"
				
					aArea := getArea()
					if ! BDK->(msSeek(xFilial("BDK")+aChave[1,2]+aChave[2,2]+aChave[3,2]+aCols[nCont,5]))

						if BA1->(msSeek(xFilial('BA1')+aChave[1,2]+aChave[2,2]+aChave[3,2]+aCols[nCont,5]))
						
							BA1->(recLock('BA1',.f.))
								BA1->BA1_MUDFAI := '1'
								BA1->BA1_FAICOB := ' '
							BA1->(msUnLock())
							
						endIf
						
					endIf
					
					restArea(aArea)
					
				endIf
				
				if nRecno == 0
					recLock(cAlias,.t.)
				else
					msGoto(nRecno)
					recLock(cAlias,.f.)
				endIf
				
				if lLogGrv
				
					_nH  := PLSAbreSem("PLUPTCOL.SMF")
					
					cSeq := PLBX1NEW()
					
					//Log de Inclusao ou Alteracao...                                          
					BX1->(recLock("BX1",.t.))
					
						BX1->BX1_FILIAL   := xFilial("BX1")
						BX1->BX1_SEQUEN   := cSeq
						BX1->BX1_ALIAS    := cAlias
						BX1->BX1_recno    := strZero(recno(),len(BX1->BX1_recno))
						BX1->BX1_TIPO     := if(nRecno==0,"I","A")
						BX1->BX1_DATA     := date()
						BX1->BX1_HORA     := time()
						BX1->BX1_USUARI   := cUsuari
						BX1->BX1_ESTTRB   := cEstTrb
						BX1->BX1_ROTINA   := cRotina
						
					BX1->(msUnLock())
					
					PLSFechaSem(_nH,"PLUPTCOL.SMF")
				endIf
				
				//correcao na gravacao da filial
				cCpoFil  := fieldName(1)
				
				if cCpoFil <> cAlias + "_FILIAL"
					
					//se a tabela tem FILIAL ..
					if ( nPos := (cAlias)->( fieldPos( cAlias + "_FILIAL" ) ) ) > 0 
						
						cCpoFil  := fieldName(nPos)
						&cCpoFil := xFilial(cAlias)
						
					else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Tabela ["+cAlias+"] sem o campo "+cAlias+"_FILIAL, contacte o desenvolvimento.", 0, 0, {})
					endIf
					
				else
					&cCpoFil := xFilial(cAlias)
				endIf
				
				for nChave  := 1 to len(aChave)
				
					cField  := aChave[nChave,1]
					cValUpt := aChave[nChave,2]
					
					//Na alteracao como a variavel ainda nao foi criada da erro se o campo nao existir  
					if TYPE(cField) <> "U"
					
						if valType(&cField) == valType(cValUpt) .and. ! (&cField == cValUpt)
							&cField := cValUpt
						endIf
						
					endIf
					
				next
				
				for nFields := 1 to len(aHeader)
				
					if aHeader[nFields,10] <> "V"
					
						cField  := allTrim(aHeader[nFields,2])
						cValUpt := aCols[nCont,nFields]
						
						cCpoFis := cAlias + "->" + allTrim(aHeader[nFields,2])
						
						if lLogGrv
						
							if ! ( &cField == cValUpt) .and. nRecno <> 0
							
								BX2->(recLock("BX2",.t.))
								
									BX2->BX2_FILIAL   := xFilial("BX2")
									BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
									BX2->BX2_CAMPO    := allTrim(aHeader[nFields,2])
									BX2->BX2_TITULO   := posicione("SX3",2,allTrim(aHeader[nFields,2]),"X3_TITULO")
									cType01           := valType(cValUpt)
									
									if cType01 == "C"
										BX2->BX2_ANTVAL   := &cField
										BX2->BX2_NOVVAL   := cValUpt
									elseIf cType01 == "N"
										BX2->BX2_ANTVAL   := str(&cField,17,4)
										BX2->BX2_NOVVAL   := str(cValUpt,17,4)
									elseIf cType01 == "D"
										BX2->BX2_ANTVAL   := dtoc(&cField)
										BX2->BX2_NOVVAL   := dtoc(cValUpt)
									endIf
									
									If FindFunction("PLSBX1BX2") 
										PLSBX1BX2(cAlias, allTrim(aHeader[nFields,2]), cValUpt, cField )
									EndIf 
									
								BX2->(msUnLock())
									
							endIf
							
						endIf
						
						if !(&cField == cValUpt)
							&cField := cValUpt
						endIf
						
					endIf
					
				next
				
				msUnLock()
				
				if nRecno == 0
				
					if (nPos := aScan(aRecAlt, { |x| x[1] == cAlias .and. x[2] == 'I' .and. x[3] == nRecno } ) ) > 0
						aRecAlt[nPos,3] := (cAlias)->(recno())
					endIf
					
				endIf	
						
			elseIf valType(nRecno) == "N"
			
				if nRecno <> 0
				
					nRecno := aVetTrab[nCont]
					
					msGoto(nRecno)
					
					if lPLSA174 .and. cAlias $ 'BDK/BBU' 
	
						aArea := getArea()
						
						if cAlias == 'BBU'

							//	se estou deletando o BBU, tenho que ver se não existe nenhum BA1 com bdk
							BA1->( msSeek( xFilial('BA1') + BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC) ) )
							
							while BA1->(!eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
								
								if !BDK->(msSeek(xFilial("BA1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))) .and. BA1->BA1_MUDFAI == '0' .and. BA1->BA1_FAICOB == &(cAlias+"->"+cAlias+"_CODFAI")
									
									BA1->(recLock('BA1',.f.))
										BA1->BA1_MUDFAI := '1'
										BA1->BA1_FAICOB := ' '
									BA1->(msUnLock())
									
								endIf
								
								BA1->(dbSkip())
							endDo
							
							
						else
						
							if BA1->( msSeek( xFilial('BA1') + BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC) + aCols[nCont,5])).and. BA1->BA1_MUDFAI == '0' .and. BA1->BA1_FAICOB == &( cAlias + "->" + cAlias + "_CODFAI" )
								
								BA1->(recLock('BA1',.f.))
									BA1->BA1_MUDFAI := '1'
									BA1->BA1_FAICOB := ''
								BA1->(msUnLock())
								
							endIf
							
						endIf
	
						restArea(aArea)
						
					endIf
					
					recLock(cAlias,.f.)
						dbDelete()
					msUnLock()
					
					if lLogGrv
					
						_nH  := PLSAbreSem("PLUPTCOL.SMF")
						cSeq := PLBX1NEW()

						//Log de Exclusao...                                                       
						BX1->(recLock("BX1",.t.))
						
							BX1->BX1_FILIAL   := xFilial("BX1")
							BX1->BX1_SEQUEN   := cSeq
							BX1->BX1_ALIAS    := cAlias
							BX1->BX1_recno    := strZero(recno(),len(BX1->BX1_recno))
							BX1->BX1_TIPO     := "E"
							BX1->BX1_DATA     := date()
							BX1->BX1_HORA     := time()
							BX1->BX1_USUARI   := cUsuari
							BX1->BX1_ESTTRB   := cEstTrb
							BX1->BX1_ROTINA   := cRotina
							
						BX1->(msUnLock())
						
						PLSFechaSem(_nH,"PLUPTCOL.SMF")
						
					endIf
					
				endIf
				
			endIf
			
		next
		
	elseIf nOpc == K_Excluir
	
		for nCont := 1 to len(aCols)
			
			if nCont > len(aVetTrab)
				nRecno := 0
			else
				nRecno := aVetTrab[nCont]
			endIf
			
			if nRecno <> 0
			
				msGoto(nRecno)
			
				recLock(cAlias,.f.)
					dbDelete()
				msUnLock()
				
				if lLogGrv
					_nH  := PLSAbreSem("PLUPTCOL.SMF")
					cSeq := PLBX1NEW()
					
					//Log de Inclusao ou Alteracao...                                          
					BX1->(recLock("BX1",.t.))
						
						BX1->BX1_FILIAL   := xFilial("BX1")
						BX1->BX1_SEQUEN   := cSeq
						BX1->BX1_ALIAS    := cAlias
						BX1->BX1_recno    := strZero(recno(),len(BX1->BX1_recno))
						BX1->BX1_TIPO     := "E"
						BX1->BX1_DATA     := date()
						BX1->BX1_HORA     := time()
						BX1->BX1_USUARI   := cUsuari
						BX1->BX1_ESTTRB   := cEstTrb
						BX1->BX1_ROTINA   := cRotina
						
					BX1->(msUnLock())
					
					PLSFechaSem(_nH,"PLUPTCOL.SMF")
				endIf
				
			endIf
			
		next
		
	endIf
	
end transaction

//Restauro area antiga...                                                  
SX3->(restArea(aAreaSX3))

if ! empty(cOldArea)
	dbSelectArea(cOldArea)
endIf

return

/*/{Protheus.doc} PLBX1NEW
Proxima numero sequencial log de campo.. 
@type function
@author PLSTEAM
@since 04.07.2000
@version 1.0
/*/
function PLBX1NEW()
local nLen := len(BX1->BX1_SEQUEN)

BX1->(dbSetOrder(2))
BX1->(msSeek( xFilial("BX1") + replicate("9",nLen),.t.))

BX1->(dbSkip(-1))

if ! BX1->(eof())
   cSeq := strZero(val(BX1->BX1_SEQUEN)+1,nLen)
else
   cSeq := strZero(1,nLen)
endIf

return(cSeq)

/*/{Protheus.doc} PLSBX1BX2
Grava BX2 da ba1 sempre que gravar BTS 
@type function
@author PLSTEAM
@since 12.06.2018
@version 1.0
/*/
function PLSBX1BX2(cAlias, cCampo, cValorUpd, cField ) 
 
LOCAL CCpoBA1 	  := ""

DEFAULT cCampo    := ""
DEFAULT cValorUpd := ""
DEFAULT cField	  := ""

If cAlias == "BTS"
		
	CCpoBA1 := "BA1" + SUBSTR(cCampo,4)
	
	If BA1->(FieldPos("BA1" + SUBSTR(cCampo,4))) > 0 
	
		BX2->(recLock("BX2",.t.))
		
			BX2->BX2_FILIAL   := xFilial("BX2")
			BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
			BX2->BX2_CAMPO    := "BA1" + SUBSTR(cCampo,4)
			BX2->BX2_TITULO   := posicione("SX3",2,CCpoBA1,"X3_TITULO")
			cType             := valType(cValorUpd)
			
			if cType == "C"
				BX2->BX2_ANTVAL   := &cField
				BX2->BX2_NOVVAL   := cValorUpd
			elseIf cType == "N"
				BX2->BX2_ANTVAL   := str(&cField,17,4)
				BX2->BX2_NOVVAL   := str(cValorUpd,17,4)
			elseIf cType == "D"
				BX2->BX2_ANTVAL   := dtoc(&cField)
				BX2->BX2_NOVVAL   := dtoc(cValorUpd)
			endIf
			
		BX2->(msUnLock())
	EndIf
EndIf

Return








