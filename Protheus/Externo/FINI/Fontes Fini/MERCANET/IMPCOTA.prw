#include 'protheus.ch'
#include 'parmtype.ch'


User function IMPCOTA()

	//Local _lContinua	:= .F.
	Local bConfirm
	Local bSair
	Local oDialog
	//Local oFont 

	Private _cFile 		:= space(60) 
	Private _GeraRel	:= .T.
	Private _aDados     := {}
	Private _cAnoProc   := space(04)  
	Private _cMesProc   := space(02)

	// Cria Fonte para visualização
 	oFont1 := TFont():New('Courier new',,-18,.T.)
	oFont2 := TFont():New('Courier new',,-16,.T.)
	oFont3 := TFont():New('Courier new',,-14,.T.)
	oFont4 := TFont():New('Courier new',,-12,.T.)

	//----------------------------------------------------
	// Obtem os últimos parâmetros salvos do usuário  
	//----------------------------------------------------
	cotaPar(.F.)

	bConfirm := {|| lOk:=validProc() , if(lOK,oDialog:DeActivate(),NIL) } //{|| MsgInfo('Insira seu processamento aqui','Processando') }
	bSair    := {|| Iif(MsgYesNo( 'Você tem certeza que deseja sair da rotina' ,;
	'Sair da rotina'),(oDialog:DeActivate()),NIL) }
	bSelect  := {|| _cFile:=cgetfile('Arquivo CSV|*.csv','Escolha o arquivo a ser processado.',,'C:\',.T.,GETF_LOCALHARD,.F.,.F.),oGet1:CtrlRefresh() }
    bPar     := {|| cotaPar(.T.) }


	// Método responsável por criar a janela e montar os paineis.
	oDialog := FWDialogModal():New()

	// Métodos para configurar o uso da classe.
	oDialog:SetBackground( .T. )
	oDialog:SetTitle( 'Importação CSV - Cotas MERCANET' )
	oDialog:SetSize( 120, 250 )
	oDialog:EnableFormBar( .T. )
	oDialog:SetCloseButton( .F. )
	oDialog:SetEscClose( .F. )
	oDialog:CreateDialog()
	oDialog:CreateFormBar()
	oDialog:AddButton( 'Selecionar', bSelect, 'Selecionar'  , , .T., .F., .T., )
	oDialog:AddButton( 'Parâmetros', bPar    , 'Parâmetros' , , .T., .F., .T., )
	oDialog:AddButton( 'Processar',  bConfirm, 'Processar'  , , .T., .F., .T., )
	oDialog:AddButton( 'Sair'     ,  bSair   , 'Sair'       , , .T., .F., .T., )
	
	oContainer := TPanel():New( ,,, oDialog:getPanelMain() )
	//oContainer:SetCss("TPanel{background-color : red;}")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	oSay1 	:= TSay():New( 008,006,{||"Esta rotina tem por objetivo ler arquivo CSV para importar os"	},oContainer,,oFont4,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)
	oSay2 	:= TSay():New( 016,006,{||"dados das cotas de vendas dos pedidos Mercanet por Vendedor/SKU "   	},oContainer,,oFont4,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)
	oSay3 	:= TSay():New( 028,006,{||"Selecione o caminho do arquivo e clique em 'Processar' para iniciar"		},oContainer,,oFont4,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)
	oSay4 	:= TSay():New( 042,006,{||"** Acesse [Parâmetros] para escolher o período a atualizar ** "    		},oContainer,,oFont4,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,250,008)
	oSay5 	:= TSay():New( 060,006,{||"Arquivo:"																},oContainer,,oFont4,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1 	:= TGet():New( 060,038,{|u| if( Pcount()>0, _cFile:= u,_cFile )},oContainer,200,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F.},.F.,.F.,,.F.,.F.,"","_cFile",,)

	// Capturar o objeto do FwDialogModal para alocar outros objetos se necessário.
	oPanel := oDialog:GetPanelMain()

	oDialog:Activate()

Return


Static Function validProc()

   Local lRet := .T. 


         if empty(_cFile)
		    FWAlertWarning("Arquivo CSV não foi selecionado.")
			return(.F.)
		 endif 

		//----------------------------------------------------------------------
		// Pergunta ao usuario para confirmar processo do período escolhido
		//----------------------------------------------------------------------
		if !FWAlertNoYes( "Confirmar processar o período " + _cMesProc + "-" + _cAnoProc + " ?" + chr(10) + chr(13) + "Caso o período já exista, as informações serão deletadas e atualizadas com os novos dados lidos do arquivo CSV.") 
			FWAlertWarning("Processo cancelado")
			return(.F.)
		endif

		//-----------------------------------------------------
		// Não permite atualizar periodo anterior a data atual
		//-----------------------------------------------------
		if _cAnoProc+_cMesProc < substring(dtos(date()),1,6) 
			FWAlertWarning("O período selecionado (" + _cAnoProc+"/"+_cMesProc+ ") deve ser maior ou igual a data atual","Atenção")
			return(.F.)
		endif

        //-----------------------------------------------------------------
		// Chama rotinas para ler o CSV e importar dados para a tabela ZCO 
		//-----------------------------------------------------------------
		processa( { || ImportArq(_cFile) }, "Aguarde","Lendo arquivo "+_cFile,.F.)
		if _GeraRel
			processa( { || geraCota(_aDados) }, "Aguarde","Atualizando base de dados... ",.F.)
		endif 


Return(lRet)



//-----------------------------------------------------------
//
//
// Lê o arquivo TXT  
//
//
//-----------------------------------------------------------
Static Function ImportArq(_cFile)

	Local _aLin	  := {}
	Local _nLin   := 0 
	Local _nCol 

	if alltrim(_cFile) == ""
		alert("Arquivo inválido")
		return 
	endif 

	FT_FUSE(_cFile)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	if !(FT_FEOF())

		while !(FT_FEOF())
			_nLin++
			IncProc("Lendo linha " + cvaltochar(_nLin) + " do arquivo " + alltrim(_cFile) + ".")
			_cLin := FT_FREADLN()

			if ';' $ _cLin
				_aLin := Separa(_cLin,";",.T.)
			else
				alert("Conteúdo do arquivo é invalido para realizar leitura")
				_GeraRel := .F.
				return()
			endif

			//Faz a carga inicial do array de acordo com o numero de colunas disponiveis
			aadd(_aDados, array(len(_aLin)))

			//Preencho o array _aDados com o conteudo de cada coluna do arquivo CSV/XLS
			for _nCol := 1 to len(_aLin)
				_aDados[_nLin][_nCol]:= _aLin[_nCol]
			next

			// Verifica se codigo de supervisor / vendedor e produto do arquivo CSV existem na base de dados
			// Caso invalido, aborta processo
            
			if _nLin > 1
				SB1->(dbSetOrder(1))
				if !SB1->(dbseek(xFilial("SB1")+_aDados[_nLin][3] ))
				FWAlertError("Código do PRODUTO inválido na linha " + strzero(_nLin-1,4,0),"Processo cancelado")
					_GeraRel := .F.
					return()
				endif

				SA3->(dbSetOrder(1))
				if !SA3->(dbseek(xFilial("SA3")+_aDados[_nLin][2] ))
				FWAlertError("Código do VENDEDOR inválido na linha " + strzero(_nLin-1,4,0),"Processo cancelado")
					_GeraRel := .F.
					return()
				endif
				// Caio Souza 28/07/2022 - Valida se existe Supervidor preenhido junto com o Vendedor
				if !Empty(_aDados[_nLin][1] ) .And. !Empty(_aDados[_nLin][2] )
				FWAlertError("Existe código de SUPERVISOR preenchido na mesma linha do VENDEDOR - linha " + strzero(_nLin-1,4,0),"Processo cancelado")
					_GeraRel := .F.
					return()
				endif

				ZOS->(dbSetOrder(1))
				if !ZOS->(dbseek(xFilial("ZOS")+_aDados[_nLin][1] ))
				FWAlertError("Código do SUPERVISOR inválido na linha " + strzero(_nLin-1,4,0),"Processo cancelado")
					_GeraRel := .F.
					return()
				endif
            endif 
			
			FT_FSKIP()
		enddo
	endif 


Return 


//-----------------------------------------------------------
//
//
// Importa na tabela de cotas  
//
//
//-----------------------------------------------------------
Static Function geraCota(_aDados)


   Local xx 
   //------------------------------------------------
   // Deleta registros do periodo escolhido antes 
   // da nova atualizacao
   //------------------------------------------------
   delZCO(_cAnoProc,_cMesProc)
	
    DbSelectArea("ZCO") 
	
	for xx := 2 to len(_aDados)

       RecLock("ZCO",.T.)
	   ZCO->ZCO_FILIAL := xFilial("ZCO")
	   ZCO->ZCO_CODSUP := _aDados[xx][1]
	   ZCO->ZCO_CODVEN := _aDados[xx][2]
	   ZCO->ZCO_CODPRO := _aDados[xx][3]
	   ZCO->ZCO_COTA   := VAL(_aDados[xx][4]) 
	   ZCO->ZCO_ANO    := _cAnoProc
	   ZCO->ZCO_MES    := _cMesProc
	   ZCO->ZCO_USRINC := cUSerNAme 
	   ZCO->ZCO_DTINC  := date() 
	   ZCO->ZCO_HRINC  := time() 
	   ZCO->(MsUnlock())
	next

	FWAlertSuccess("Importação do arquivo " + _cFile + " finalizado.")

Return

//-----------------------------------------------
// Funcao para deletar registro da ZCO 
//-----------------------------------------------
Static Function delZCO(_cAnoProc,_cMesProc)

Local cQry 

cQry := "UPDATE ZCO010 SET D_E_L_E_T_='*',R_E_C_D_E_L_=R_E_C_N_O_  " 
cQry += " , ZCO_USREXC = '" + cUSerName  + "' , ZCO_DTEXC ='" + dtos(date()) + "',  ZCO_HREXC = '" + substr(time(),1,5)  + "'"
cQry += " WHERE D_E_L_E_T_ = '' AND ZCO_ANO = '" + _cAnoProc + "' AND ZCO_MES = '" + _cMesProc  + "' "

TCSQLEXEC(cQry)

Return



//------------------------------------------------------
// Função para obter parametros do usuario 
//------------------------------------------------------
Static Function cotaPar(lTela) 

	if lTela 
		if !pergunte("IMPCOTA" , lTela )
	   		FWAlertInfo("Processo cancelado pelo usuário", "Cotas")
	   		RETURN
		else
	   		_cAnoProc := strzero(MV_PAR01,4,0) 
	   		_cMesProc := strzero(MV_PAR02,2,0) 
		endif
	else  
        pergunte("IMPCOTA" , lTela )	
		_cAnoProc := strzero(MV_PAR01,4,0) 
   		_cMesProc := strzero(MV_PAR02,2,0)   
	endif 

Return 
