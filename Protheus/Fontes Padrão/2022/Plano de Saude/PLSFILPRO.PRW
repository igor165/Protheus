#INCLUDE "RWMAKE.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TOTVS.CH"
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSFILPRO Ё Autor Ё Totvs					Ё Data Ё 07/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Abre o pergunte e retorna filtro conforme selecao  		  Ё╠╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддд
ддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSFILPRO()
LOCAL cFConteudo 	:= ""  
LOCAL cFiltro		 	:= ""
LOCAL lRet		        := .T.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Inicia pergunta
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if pergunte("PLSFILPRO",.T.,"Parametros Filtragem")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Rede de atendimento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !Empty(MV_PAR01) 
	    cFConteudo 	+= " and BXX_CODRDA = '"+MV_PAR01+"' "
	endIf                                      
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Data de processamento
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !Empty(MV_PAR02) .and. !Empty(MV_PAR03)
	    cFConteudo 	+= " and BXX_DATMOV >= '"+dtos(MV_PAR02)+"' and BXX_DATMOV <= '"+dtos(MV_PAR03)+"'" 
	endIf             
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Status 0=NЦo Processado;1=Acatado;2=Nao acatado;3=Processado
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//'0=Em processamento - 'BR_VERMELHO';1=Acatado - 'BR_VERDE';2=Nao acatado-'BR_LARANJA_OCEAN';3=Processado-'BR_CINZA''  
	//aAdd(aRegs,{cPerg,"04","Status?"				,"","","MV_CH4","N",1  ,0,1,"C","","MV_PAR04","Todos","","","","","NЦo acatado","","","","","Acatado","","","","","Processado","","","","","","","","","","S","","","",""})

	if MV_PAR04 > 1 
	    If MV_PAR04 == 2
	    	cFConteudo 	+= " and BXX_STATUS = '"+cValToChar(2)+"'" 
		Elseif MV_PAR04 == 3
			cFConteudo 	+= " and BXX_STATUS = '"+cValToChar(1)+"'" 
		Elseif MV_PAR04 == 4
			cFConteudo 	+= " and BXX_STATUS = '"+cValToChar(3)+"'" 
		Endif
	endIf 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Usuario
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !empty(MV_PAR05) 
	    cFConteudo 	+= " and BXX_CODUSR = '"+UPPER(MV_PAR05)+"'" 
	endIf 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Envio do portal
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if MV_PAR06 > 1 
	    cFConteudo 	+= " and BXX_TPNFS = '"+cValToChar(MV_PAR06-2)+"'" 
	endIf 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Executa filtro
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	
	if !empty(cFConteudo)
		cFiltro := "BXX_FILIAL = '"+xFilial("BXX")+"' and BXX_CODINT = '"+PLSINTPAD()+"' " +cFConteudo + " and D_E_L_E_T_ = ' ' "
	Else
		cFiltro := "BXX_FILIAL = '"+xFilial("BXX")+"' and BXX_CODINT = '"+PLSINTPAD()+"' and D_E_L_E_T_ = ' ' "
	Endif
	
	PCOLS(cFiltro)
	
	if Type('oSayMsg01') <> 'U'
		oSayMsg01:cCaption := "  Estao sendo exibidos os registros de acordo com os parametros selecionados"	                                
		oSayMsg01:refresh()
	endIf
			
	if Type('oSayMsg02') <> 'U'
		oSayMsg02:cCaption := ""
		oSayMsg02:refresh()
	endif

Else
	lRet := .F.
Endif

Return(lRet)

static function PCOLS(cFiltro)   
local nX := 1 
local nLimite := GetNewPar("MV_PLLIARU",500)	    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё selecionando registros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BXX->( dbGoTop() )
BXX->( dbSetorder(1) )//BXX_FILIAL + BXX_CODINT + BXX_CODRDA + BXX_ARQIN
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё sempre tem que limpar a atrab para manter o sincronizado
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//_aTrbBXX  := {}   
_aColsBXX := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё selecionando registros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if ! BXX->( msSeek( xFilial("BXX")+PLSINTPAD() ) )
   nPosSequen := aScan(_aHeaderBXX,{|x|AllTrim(x[2])=="R_E_C_N_O_"} ) 
    i:=0
    _aHeaderBXX[Len(_aHeaderBXX), 2] := "BXX_SEQUEN" // atualiza titulo do campo para nao validar o SX3

	BXX->(MsGoto(0))
	Store COLS Blank "BXX" TO _aColsBXX FROM _aHeaderBXX

    nPosSequen := aScan(_aHeaderBXX,{|x|AllTrim(x[2])=="BXX_SEQUEN"} )
    i:=0
    _aHeaderBXX[Len(_aHeaderBXX), 2] := "R_E_C_N_O_" // atualiza titulo do campo para nao validar o SX3
else
	//store COLS "BXX" TO _aColsBXX FROM _aHeaderBXX VETTRAB _aTrbBXX While BXX->(BXX_FILIAL+BXX_CODINT) == xFilial("BXX")+PLSINTPAD()   
	
	cQuery := ""	    
    lQuery := .T.
    cAliasBXX := "QRYBXX"
       
    cQuery := "SELECT COUNT(*) CNT"
    cQuery += " FROM "
    cQuery += RetSqlName("BXX")+ " BXX "
    cQuery += " WHERE "
    cQuery += cFiltro
    cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasBXX,.F.,.T.)
    If !QRYBXX->(Eof()) .and. QRYBXX->CNT > nLimite
		MsgStop("Este filtro retornou mais que "+alltrim(str(nLimite))+" registros, serЦo listados somente os "+str(nLimite)+" primeiros.")  
    Endif                           
	QRYBXX->(dbCloseArea())
    
    cQuery := "SELECT * "
    cQuery += " FROM "
    cQuery += RetSqlName("BXX")+ " BXX "
    cQuery += " WHERE "
    cQuery += cFiltro
    cQuery += "ORDER BY R_E_C_N_O_ DESC"
    
	PlsQuery(cQuery,cAliasBXX)
	
	i:=0
	While !Eof()
		i++
		If i > nLimite
			exit
		Endif
		Aadd(_aColsBXX,Array(Len(_aHeaderBXX)+1))

		BXX->(MsGoto((cAliasBXX)->R_E_C_N_O_))		

		For nX := 1 To Len(_aHeaderBXX)
			If ( _aHeaderBXX[nX,10] !=  "V" )
				_aColsBXX[Len(_aColsBXX)][nX] := (cAliasBXX)->(FieldGet(FieldPos(_aHeaderBXX[nX,2])))
			Else
				_aColsBXX[Len(_aColsBXX)][nX] := CriaVar(_aHeaderBXX[nX,2],.T.)
			EndIf
		Next nX
		_aColsBXX[Len(_aColsBXX)][Len(_aHeaderBXX)+1] := .F.
		
		//Aadd(_aTrbBXX, (cAliasBXX)->R_E_C_N_O_ )
		
		dbSelectArea(cAliasBXX)
		dbSkip()				
		
	EndDo

	If Empty(_aColsBXX)
	    nPosSequen := aScan(_aHeaderBXX,{|x|AllTrim(x[2])=="R_E_C_N_O_"} ) 
	    i:=0
	    _aHeaderBXX[Len(_aHeaderBXX), 2] := "BXX_SEQUEN" // atualiza titulo do campo para nao validar o SX3

		BXX->(MsGoto(0))
		Store COLS Blank "BXX" TO _aColsBXX FROM _aHeaderBXX

	    nPosSequen := aScan(_aHeaderBXX,{|x|AllTrim(x[2])=="BXX_SEQUEN"} )
	    i:=0
	    _aHeaderBXX[Len(_aHeaderBXX), 2] := "R_E_C_N_O_" // atualiza titulo do campo para nao validar o SX3
	EndIf

	(cAliasBXX)->(dbCloseArea())	
	dbSelectArea("BXX")		

	
endIf	         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza browse
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if valType(_oBrwBXX) == 'O'      
	_oBrwBXX:setArray(_aColsBXX) 
	_oBrwBXX:forceRefresh()
	_oBrwBXX:refresh()
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina                                                            
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return(nil)                                      
