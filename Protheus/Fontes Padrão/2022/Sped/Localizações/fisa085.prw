#INCLUDE "FISA085.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"                      
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"


#DEFINE NAO_TRANSMITIDO		"0"
//#DEFINE CANCELADO 		1 //Legenda descontinuada a partir das novas abaixo
#DEFINE TRANSMITIDO			"2"
#DEFINE AUTORIZADO			"3"
//#DEFINE NAO_AUTORIZADO	4 //Legenda descontinuada a partir das novas abaixo
#DEFINE NAO_RONDA			"5"
#DEFINE NAO_DGI				"6"
#DEFINE ANULADO				"7"
#DEFINE ANU_TRANS			"8"
#DEFINE ANU_AUTORIZADA		"9"
#DEFINE ANU_NAO_AUTOR		"10"

#DEFINE TPDOC_ALQUILER		'4'
#DEFINE TPDOC_HONORARIOS	'5'                          
#DEFINE TPDOC_LIMP			'6'

#DEFINE NBYTES_READ 40960 

#DEFINE TYPE_CFE 	1
#DEFINE TYPE_RESG 	2

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fisa085()
Rotina de geração e transmissão de resguardos do Uruguai

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fisa085()
Local   aCores:={}
Private aSize	:= MsAdvSize(.T.)
Private aRotina := MenuDef()
Private cpMarca	:= GetMark()



aCores:={	{"Alltrim(CLE->CLE_STATUS) == '0'",'BR_VERMELHO'},;
			{"Alltrim(CLE->CLE_STATUS) == '2'",'BR_AMARELO'},;
			{"Alltrim(CLE->CLE_STATUS) == '3'",'BR_VERDE'},;
			{"Alltrim(CLE->CLE_STATUS) == '5'",'BR_AZUL'},;		
			{"Alltrim(CLE->CLE_STATUS) == '6'",'BR_PRETO'},;
			{"Alltrim(CLE->CLE_STATUS) == '7'",'BR_PINK'},;
			{"Alltrim(CLE->CLE_STATUS) == '8'",'BR_MARRON'},;
			{"Alltrim(CLE->CLE_STATUS) == '9'",'BR_LARANJA'}}
		
Pergunte("FISA085",.F.)
If SX1->(dbSeek(PadR("FISA085",Len(SX1->X1_GRUPO))+"12"))
		RecLock("SX1",.F.)
			SX1->X1_CNT01   := GETMV("MV_SERRESG")
		MsUnLock()
	EndIf
	


	MV_PAR12:=GETMV("MV_SERRESG")	

                  
	dbSelectArea('CLE')
	CLE->(dbSetOrder(1))	
	mBrowse( 6,1,22,75,"CLE",,,,,,aCores/*Fa040Legenda("SE1")*/)
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085Gera
Gera um novo resguardo para a tabela CLE / CLF

@author  Paulo Pouza
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F085Gera()

Local lAviso1	:= .T.
Local lAviso2	:= .T.
Local lExc		:= .F.
Local clPerg	:= "FISA085"
Local clQryTl	:= ""
Local cTmp		:= ""
Local clDescImp	:= ""
Local cPref 	:= ""
Local cArqTMP1	:= ""
Local cNumDoc	:= ""                                               
Local cSerie	:= ""
Local cCliFor	:= ""
Local cLoja		:= ""
Local cEspecie	:= ""
Local cConcept	:= ""
Local cChave    := ""
Local cIndice   := ""
Local cTes    	:= ""
Local cEmissao	:= ""
Local cDtDigit	:= ""
Local cDesri	:=""
Local aStrutTMP1:= {}
Local alCertRet	:= {}
Local aCertPend	:= {}	
Local alDelTits := {}
Local olDlg		:= NIl
Local nlI       := 0
Local nOpcao    := 0 
Local nlOpc		:= 0 
Local nValImp1  := 0
Local nValImp2  := 0
Local nValImp3  := 0
Local nValImp4  := 0
Local nValImp6  := 0
Local nBasImp2  := 0
Local nBasImp3  := 0
Local nBasImp4  := 0
Local nBasImp6  := 0
Local nAlqImp2  := 0
Local nAlqImp3  := 0
Local nAlqImp4  := 0
Local nAlqImp6  := 0
 
 /*                 
//Saccem
Local cLivIRP	:= Subs(GetNewPar("MV_LFRESG"), 1, 1)
Local cLivIRA	:= Subs(GetNewPar("MV_LFRESG"), 2, 1)
Local cLivIRN	:= Subs(GetNewPar("MV_LFRESG"), 3, 1)
Local cLivIRV	:= Subs(GetNewPar("MV_LFRESG"), 4, 1)
   */
   
   
Private dDtIni  := Ctod("//")
Private dDtFim  := Ctod("//")
Private cCodIni	:= ""
Private cLojIni	:= ""
Private cCodFim	:= ""
Private cLojFim	:= ""
Private cDocIni	:= ""
Private cSerIni	:= ""
Private cDocFim	:= ""
Private cSerFim	:= ""              

Private nTipOpe		:= 0
Private nTipImp     := 0
Private nMoeda		:= 1
Private nTxMoeda  	:= 1
Private llMarc	    := .T.
Private apCampos	:= {}
Private TMP1	:= ""
Private oTmpTable

If Pergunte(clPerg,.T.)
	
	cTipResg 	:=MV_PAR01 //Tipo de Imposto(Equador-IVA|IR|Ambos,Outros-IVA|ICA|Fonte)
	dDtIni  	:=MV_PAR02//Data Inicial
	dDtFim  	:=MV_PAR03//Data Final
	cCodIni		:=MV_PAR04//Cli/For Inicial|Fornecedor Inicial
	cLojIni		:=MV_PAR05//Loja Inicial
	cCodFim		:=MV_PAR06//Cli/For Final|Fornecedor Final
	cLojFim		:=MV_PAR07//Loja Final
	cDocIni		:=MV_PAR08//Documento Inicial
	cSerIni		:=MV_PAR09//Serie Inicial
	cDocFim		:=MV_PAR10//Documento Final
	cSerFim		:=MV_PAR11//Serie Final
	nOpcao  	:=1 //MV_PAR12//Opcao(Equador-Cadastrar,Re-Imprimir,Excluir|Outros-Imprimir,Re-Imprimir,Excluir)
	
	nTipOpe:= 1 
	If Type("cTipResg")=="N"
		cTipResg:=Alltrim(Str(cTipResg))
	EndIf
	
	//Equador-Cadastrar|Outos Paises-Imprimir	
	If nOpcao == 1
		
		cTabTemp := criatrab(nil,.F.)
		clQryTl := "" 


		clQryTl += "SELECT '  ' AS OK, FE_FORNECE, FE_LOJA, FE_ESPECIE, FE_SERIE,FE_NFISCAL,FE_NROCERT,FE_EMISSAO,FE_VALBASE,FE_ALIQ,FE_VALIMP,CLB_CODDGI,CLB_DESCRI,FE_TIPIMP,FE_GRPTRIB"
		clQryTl += " FROM "+RetSqlName("SFE")+       " SFE "
		clQryTl += "	 	INNER JOIN " +RetSqlName("CLB")+       " CLB "
		clQryTl += "        ON CLB.D_E_L_E_T_ = ' '  "
		clQryTl += "        AND CLB_IMP = FE_TIPIMP "
		clQryTl += " 		AND  CLB_CODT = FE_GRPTRIB AND CLB_TPRESG = '"       + cTipResg + "'"   
		clQryTl += "        AND FE_EMISSAO BETWEEN '" + dtos(dDtIni)   + "' AND '" +dtos(dDtFim)+ "'"
		clQryTl += "        AND FE_FILIAL = '"       + xFilial("SFE") + "'" 
   //		clQryTl += "        AND FE_VALIMP >0" 
		clQryTl += "        AND FE_FORNECE BETWEEN '"+cCodIni+"' AND '"+cCodFim+"'"
		clQryTl += "        AND FE_LOJA BETWEEN '"+cLojIni+"' AND '"+cLojFim+"'"
		clQryTl += "        AND FE_NFISCAL BETWEEN '"+cDocIni+"' AND '"+cDocFim+"'"
		clQryTl += "        AND FE_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"'"

		clQryTl += " 		WHERE  SFE.D_E_L_E_T_ = ' '  "
 		 
 	 	clQryTl += "ORDER BY FE_FORNECE,FE_LOJA,FE_TIPIMP"
 		 
 		 
		//Monta um arquivo de trabalho
		aStrutTMP1:={}
		AADD(aStrutTMP1,{"OK" 	        	,"C",002,0})   
		AADD(aStrutTMP1,{"FE_NFISCAL" 		,"C",TamSx3("FE_NFISCAL")[1],0})
		AADD(aStrutTMP1,{"FE_SERIE"	    ,"C",TamSx3("FE_SERIE")[1],0})
		AADD(aStrutTMP1,{"FE_FORNECE"    ,"C",TamSx3("FE_FORNECE")[1],0})
		AADD(aStrutTMP1,{"FE_ESPECIE"    ,"C",TamSx3("FE_ESPECIE")[1],0})
		AADD(aStrutTMP1,{"FE_LOJA"		,"C",TamSx3("FE_LOJA")[1],0})
		AADD(aStrutTMP1,{"FE_EMISSAO"	,"D",TamSx3("FE_EMISSAO")[1],0})
		AADD(aStrutTMP1,{"FE_VALBASE"	    ,"N",TamSx3("FE_VALBASE")[1],2})			
		AADD(aStrutTMP1,{"FE_ALIQ"	,"N",TamSx3("FE_ALIQ")[1],TamSx3("FE_ALIQ")[2]}) 
		AADD(aStrutTMP1,{"FE_VALIMP"	,"N",TamSx3("FE_VALIMP")[1],TamSx3("FE_VALIMP")[2]})
		AADD(aStrutTMP1,{"FE_TOTAL"	,"N",TamSx3("FE_VALIMP")[1],TamSx3("FE_VALIMP")[2]})		
		AADD(aStrutTMP1,{"CODDGI"		,"C",8,0})		
		AADD(aStrutTMP1,{"IMP"		,"C",3,0})
		AADD(aStrutTMP1,{"DESCRI"		,"C",30,0})
		
		 If Select("TMP1")>0
            TMP1->(dbCloseArea())
            FErase(cTmp+GetDBExtension())
        Endif
		
		 
		oTmpTable := FWTemporaryTable():New("TMP1")
		oTmpTable:SetFields( aStrutTMP1 )
		
		aOrdem := {"FE_NFISCAL","FE_SERIE","FE_ESPECIE","FE_LOJA","FE_EMISSAO"}



		oTmpTable:AddIndex("TMPORD1", aOrdem)

		//Creacion de la tabla
		oTmpTable:Create()
		 
		/*****************************************************************/
		/* Agrega Punto de entrada para modificar tabla auxiliar y query */
		/*****************************************************************/
		If ExistBlock("FIS85TMP1")
			aStrutTMP1 := ExecBlock("FIS85TMP1",.F.,.F.,{aStrutTMP1,clQryTl})
		Endif
		
		clQryTl	:= ChangeQuery(clQryTl)
		
		If Select("TMP")>0
			DbSelectArea("TMP")
			TMP->(dbCloseArea())
		Endif
		      
	   //	TcQuery clQryTl New Alias "TMP"
	   
	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryTl),cTabTemp,.T.,.T.)
		TCSetField(cTabTemp,"FE_EMISSAO","D")
 		
		If (cTabTemp)->(!Eof())
			 
		/*	If Select("TMP1")>0
				DbSelectArea("TMP1")
				TMP1->(DbCloseArea())
			Endif
			*/
			//Cria o arquivo de trabalho montado na etapa anterior	
			//cIndTMP1	:=	CriaTrab(aStrutTMP1,.F.)
			//cArqTMP1	:=	CriaTrab(aStrutTMP1)
			//dbUseArea(.T.,__LocalDriver,cArqTMP1,"TMP1")	       
            
			DbSelectArea((cTabTemp))
			(cTabTemp)->(DbGoTop())				
			Do While (cTabTemp)->(!Eof())
				CLF->(DbSetOrder(2))
				CLE->(dbsetorder(1)) // CLE_FILIAL+CLE_TPRESG+CLE_SERIER+CLE_NUMREG  

				If	!CLF->(DbSeek(xFilial("CLF")+PADR((cTabTemp)->FE_ESPECIE,len(CLF->CLF_ESPECI))+(cTabTemp)->FE_SERIE+(cTabTemp)->FE_NFISCAL+(cTabTemp)->FE_FORNECE+(cTabTemp)->FE_LOJA+(cTabTemp)->FE_TIPIMP))  .or. (CLF->(DbSeek(xFilial("CLF")+PADR((cTabTemp)->FE_ESPECIE,len(CLF->CLF_ESPECI))+(cTabTemp)->FE_SERIE+(cTabTemp)->FE_NFISCAL+(cTabTemp)->FE_FORNECE+(cTabTemp)->FE_LOJA +(cTabTemp)->FE_TIPIMP  )) .and. CLE->(DBSEEK(xFilial("CLE") + CLF->(CLF_TPRESG+CLF_SERIER+ CLF_NUMREG)) .AND.  CLE->CLE_STATUS == ANU_TRANS  )  )
					nMoeda	:= 1
					nTxMoeda:= 1 
					cNumDoc	:= (cTabTemp)->FE_NFISCAL
					cSerie	:= (cTabTemp)->FE_SERIE
					cCliFor	:= (cTabTemp)->FE_FORNECEDOR
					cLoja	:= (cTabTemp)->FE_LOJA
					cEspecie:= (cTabTemp)->FE_ESPECIE
					cEmissao:= (cTabTemp)->FE_EMISSAO
					cDtDigit:= (cTabTemp)->FE_EMISSAO
					cImp	:=(cTabTemp)->FE_TIPIMP
	                cCodDGI:= (cTabTemp)->CLB_CODDGI 
	                cDesri:= (cTabTemp)->CLB_DESCRI
	                nAlqImp:= 0
	                nValImp:= 0
	                nBasImp:= 0
	    		    nTotal  := 0                   
	                lNota:=.F.                   
					Do While (cTabTemp)->(!Eof()) .And. ;
						Alltrim(cNumDoc)+Alltrim(cSerie)+Alltrim(cCliFor)+Alltrim(cLoja)+Alltrim(cImp)==;
						Alltrim((cTabTemp)->FE_NFISCAL)+Alltrim((cTabTemp)->FE_SERIE)+Alltrim((cTabTemp)->FE_FORNECEDOR)+Alltrim((cTabTemp)->FE_LOJA)+Alltrim((cTabTemp)->FE_TIPIMP)
	                        
	      				If !lNota
		      		
		       // 	    	If (cTabTemp)->FE_VALBASE >0   //IRPF
								nAlqImp:=(cTabTemp)->FE_ALIQ
								nValImp+=(cTabTemp)->FE_VALIMP 
								nBasImp+=(cTabTemp)->FE_VALBASE			                    
				 //  		   Endif          
					
	                
	           				nTotal+=(cTabTemp)->FE_VALIMP
	               			lNota:=.T.
	               		EndIf
	               		(cTabTemp)->(DbSkip())
					End
					
				RecLock("TMP1",.T.)
				TMP1->OK	  := ' '
				TMP1->FE_NFISCAL    := cNumDoc
				TMP1->FE_SERIE   := cSerie
				TMP1->FE_ESPECIE := cEspecie
				TMP1->FE_FORNECE  := cCliFor
				TMP1->FE_LOJA    := cLoja
				TMP1->FE_EMISSAO := cEmissao
				TMP1->FE_VALBASE := nBasImp
				TMP1->FE_VALIMP := nValImp
				TMP1->FE_ALIQ := nAlqImp
				TMP1->FE_TOTAL   := nTotal
				TMP1->CODDGI 	:= cCodDGI
				TMP1->IMP 		:= cImp 
				TMP1->DESCRI	:= cDesri
				
				/****************************************************************************/
				/* Agrega Punto de entrada para modificar datos al cargar la tabla auxiliar */
				/****************************************************************************/
				If ExistBlock("FIS85ARR")
					ExecBlock("FIS85ARR",.F.,.F.)
				Endif
				
				TMP1->(MsUnlock())
	    		Else
	    			(cTabTemp)->(DbSkip())
    			EndIf
    		End
			DbSelectArea("TMP1")
			TMP1->(DbGoTop())			
			aAdd(apCampos,{"OK"			, , ""		,""	,,})				
			aAdd(apCampos,{"FE_NFISCAL"			, , STR0001	,""	,,}) // "Fatura"
			aAdd(apCampos,{"FE_SERIE"		, , STR0002	,""	,,}) // "Séire"
			aAdd(apCampos,{"FE_ESPECIE"		, , STR0022,"" ,,}) // "Especie"
			aAdd(apCampos,{"FE_FORNECE"     	, , STR0003,""	,,})// "Fornecedor"|"Cliente"
			aAdd(apCampos,{"FE_LOJA"	    , , STR0004	,""	,,}) // "Loja"
			aAdd(apCampos,{"FE_EMISSAO"		, , STR0005	,""	,,}) // "Emissão"
			aAdd(apCampos,{"IMP"		, , "Imposto"	,"" ,,}) // "Entrada"
	  //		aAdd(apCampos,{cPref+"_TES"		    , , STR0050	,"" ,,}) // "Tes"				
			aAdd(apCampos,{"FE_TOTAL "	    , , STR0007	,Pesqpict("SD1","D1_TOTAL")	}) // "Valor Fatura"				
			clDescImp:=""
			clDescImp	+= "Alquiler"
			aAdd(apCampos,{"FE_VALBASE"	, ,"Bas Imp" ,Pesqpict("SFE","FE_VALBASE")})//"Bs.IVA 30%" 
			aAdd(apCampos,{"FE_ALIQ"	, ,"Alc Imp" ,Pesqpict("SFE","FE_ALIQ")	})//"Alq.IVA 30%"
			aAdd(apCampos,{"FE_VALIMP"	, ,"Val Imp" ,Pesqpict("SFE","FE_VALIMP")	})//"Vlr.IVA 30%"
			
			/**************************************************************/
			/* Agrega Punto de entrada para agregar los titulos a la Tela */
			/**************************************************************/
			If ExistBlock("FIS85APC")
				apCampos:=ExecBlock("FIS85APC",.F.,.F.,{apCampos})
			Endif
	
		Else
			Aviso(STR0035,STR0037,{STR0021})//"Certificado de Retencao Entrada"###"As Notas Fiscais de acordo com os parametros nao foi encontrado na base de dados. "###"OK"
			Return         
		Endif
		
		//Pinta a tela com os dados selecionados
		Define MsDialog olDlg Title STR0011 From aSize[1],aSize[2]-12 TO aSize[1]+600,aSize[2]+788 Pixel					//Dialog		
		olDlg:bInit := {|| EnchoiceBar(olDlg, {|| F085Inc(nTipOpe),olDlg:End()	} , {|| olDlg:End() } ,, /*Fn220But()*/) }
		
		@ aSize[1]+32,aSize[2]-25 Group oGrpImps To aSize[1]+294,aSize[2]+368 Label clDescImp Of olDlg Pixel				//Box
		oBtALL := tButton():New(aSize[1]+271,aSize[2]-2	,STR0012,olDlg,{|| FMarca( llMarc)},60,10,,,,.T.) 			// "Selecionar Todas"
		oBtOFF := tButton():New(aSize[1]+271,aSize[2]+065	,STR0013,olDlg,{|| FMarca(!llMarc)},60,10,,,,.T.) 			// "Desmarcar Todas"
        
  		If Select("TMP1")>0  
  		
			olMark:=MsSelect():New("TMP1","OK",,apCampos,,@cpMarca,{aSize[1]+42,aSize[2]- 18,aSize[1]+250,aSize[2]+365})
			olMark:oBrowse:lhasMark := .T.
			olMark:oBrowse:lCanAllmark := .F.			
			ACTIVATE MSDIALOG olDlg CENTERED
		Else 
			Aviso(STR0011,STR0037,{STR0021})
			Return
		EndIf	
		
		If Select("TMP1")>0
			TMP1->(dbCloseArea())
			FErase(cTmp+GetDBExtension())
		Endif
		
		//Exclui a tabela 
		oTmpTable:Delete() 
	EndIf
Endif

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085Inc()
Realiza a inclusao de um novo resguardo 

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function F085Inc(nTipOpe,aGerSfe)
Local cMsgCert  := ""
Local cChvCert  := ""
Local cChvNota  := ""
Local llImpri	:= .F.
Local nTotRet:= 0    
Local nx:=1
Local lgera :=.F.
Local lAchouSer:=.F.
Local aNotRet:={}
Private aCerts		:=	{}
Default aGerSfe := {}


If SX5->(dbSeek(xFilial("SX5")+"01"+MV_PAR12))
	lAchouSer:=.T.
Endif 				


If !lAchouSer
	MsgStop(STR0083 +MV_PAR12) 
	Return
EndIf

        
If Len(aGerSfe)==0      
	If Select("TMP1")>0
 		aImp:={}
 		cChvNota:="" 		
 		llImpri:=.T.
	 	DbSelectArea("TMP1")
		TMP1->(DbGoTop())              
		lgera:=.F.
		
		
		Do While TMP1->(!Eof())        
			If TMP1->FE_VALIMP==0   .and. !Empty(TMP1->OK)
				Aadd(aNotRet,{TMP1->IMP,TMP1->FE_ESPECIE,TMP1->FE_NFISCAL,TMP1->FE_SERIE,TMP1->FE_EMISSAO,TMP1->FE_ALIQ,TMP1->FE_VALBASE,TMP1->CODDGI,TMP1->DESCRI,TMP1->FE_FORNECE,TMP1->FE_LOJA})
			EndIf		
		 	If TMP1->FE_VALIMP>0   .and. !Empty(TMP1->OK)   
				lgera:=.T.
				Begin Transaction
				cMsgCert:=""
				cChvCert:=""		
				aImp:=GerNumCert(MV_PAR12,1)
						//Cabecalho			
				dbSelectArea("CLE")			
				RecLock("CLE",.T.)
				CLE->CLE_FILIAL	:= xFilial("CLE")					//Filial que está gerando o certificado
				CLE->CLE_TPRESG := MV_PAR01		 			//Tipo de Imposto
				CLE->CLE_SERIER := aImp[1]		 			//Serie do Resguardo
				CLE->CLE_NUMREG	:= aImp[2]		  			//Numero do Resguardo
				CLE->CLE_FORNEC	:= TMP1->FE_FORNECE		   			//Codigo do Fornecedor
				CLE->CLE_LOJA	:= TMP1->FE_LOJA		   			//Loja			
				CLE->CLE_MDDOC	:= "1"		   			//Moeda
				CLE->CLE_DTRESG	:= dDataBase						//Data Emissao
				CLE->CLE_OBS	:= "Gerado e nao transmitido"		//Observacao
				CLE->CLE_STATUS := NAO_TRANSMITIDO 
									//Status do resguardo
				CLE->CLE_IMP	:= 	TMP1->IMP
				CLE->(msUnlock())
	    	
			
				cimp:=  TMP1->IMP
				cForn:= TMP1->FE_FORNECE
				cLoja:= TMP1->FE_LOJA
       		
				While	cimp ==  TMP1->IMP  .And. cForn == TMP1->FE_FORNECE .And. cLoja == TMP1->FE_LOJA	
					            
		            If TMP1->FE_VALIMP>0   .and. !Empty(TMP1->OK)
		
						DbSelectArea("CLF")
						RecLock("CLF",.T.)
						CLF->CLF_FILIAL	:= xFilial("CLF")				//Filial que está gerando o certificado
						CLF->CLF_TPRESG	:= 	CLE->CLE_TPRESG				//Tipo de Imposto
						CLF->CLF_SERIER	:= 	CLE->CLE_SERIER				//Numero Certificado REVER			
						CLF->CLF_NUMREG	:= 	CLE->CLE_NUMREG				//Numero do Resguardo
						CLF->CLF_ESPECI	:=	TMP1->FE_ESPECIE			//Tipo NF
						CLF->CLF_NUM	:= 	TMP1->FE_NFISCAL			//Num NF
						CLF->CLF_SERIE	:= 	TMP1->FE_SERIE			//Serie NF
						CLF->CLF_DTEMDC	:=  TMP1->FE_EMISSAO	//Dt Emissao NF
						CLF->CLF_FORNEC	:= 	CLE->CLE_FORNEC				//Codigo do Fornecedor
						CLF->CLF_LOJA	:= 	CLE->CLE_LOJA				//Loja
						CLF->CLF_TXDOC	:=  1	  		//Taxa da Moeda           
					
						CLF->CLF_ALQIM	:= TMP1->FE_ALIQ		//Aliquota para o Calculo IRPF	        
						CLF->CLF_BASIM	:= TMP1->FE_VALBASE		//Base de calculo da retenção IRPF
						CLF->CLF_VALIM	:= TMP1->FE_VALIMP		//Valor do imposto da retenção IRPF
						CLF->CLF_CODDGI := TMP1->CODDGI			//	cODIGO dgi//Codigo de Retorno do IRPF
						CLF->CLF_IMP 	:= TMP1->IMP
						CLF->CLF_DESCRI	:= TMP1->DESCRI
						CLF->(MsUnLock())      
						nTotRet += TMP1->FE_VALIMP	//Monta os totalizadores de retencoes + seus valores
					EndIf
		     
					TMP1->(dbSkip())
					lExist:=.T.
				EndDo
				If lExist .and. Len(aNotRet)>0
					For nx:=1 to Len(aNotRet) 
				    	If aNotRet[nX][1] == cimp .and. cForn == aNotRet[nX][10] .And. cLoja == aNotRet[nX][11] .And. aNotRet[nx][7] >0 
				    
				     		DbSelectArea("CLF")
							RecLock("CLF",.T.)
							CLF->CLF_FILIAL	:= xFilial("CLF")				//Filial que está gerando o certificado
							CLF->CLF_TPRESG	:= 	CLE->CLE_TPRESG				//Tipo de Imposto
							CLF->CLF_SERIER	:= 	CLE->CLE_SERIER				//Numero Certificado REVER			
							CLF->CLF_NUMREG	:= 	CLE->CLE_NUMREG				//Numero do Resguardo
							CLF->CLF_ESPECI	:=	aNotRet[nx][2]			//Tipo NF
							CLF->CLF_NUM	:= 	aNotRet[nx][3]			//Num NF
							CLF->CLF_SERIE	:= 	aNotRet[nx][4]			//Serie NF
							CLF->CLF_DTEMDC	:=  aNotRet[nx][5]	//Dt Emissao NF
							CLF->CLF_FORNEC	:= 	cForn				//Codigo do Fornecedor
							CLF->CLF_LOJA	:= 	cLoja				//Loja
							CLF->CLF_TXDOC	:=  1	  		//Taxa da Moeda           
							CLF->CLF_ALQIM	:= aNotRet[nx][6]		//Aliquota para o Calculo IRPF	        
							CLF->CLF_BASIM	:= aNotRet[nx][7]		//Base de calculo da retenção IRPF
							CLF->CLF_VALIM	:= 0		//Valor do imposto da retenção IRPF
							CLF->CLF_CODDGI := aNotRet[nx][8]			//	cODIGO dgi//Codigo de Retorno do IRPF
							CLF->CLF_IMP 	:= aNotRet[nx][1]
							CLF->CLF_DESCRI	:= aNotRet[nx][9]
							CLF->(MsUnLock())      
							aNotRet[nx][7]:=0
							nTotRet += TMP1->FE_VALIMP	//Monta os totalizadores de retencoes + seus valores  
						EndIf
					Next
				
				EndIf
				
				If lExist		
					RecLock('CLE',.F.)
		  //		CLE->CLE_VALIMP := cCodRet
		   			CLE->CLE_VALIMP := nTotRet 
					CLE->CLE_TOTRET	:= nTotRet
					CLE->(msUnlock())
				EndIf
				End  Transaction
			Else
				TMP1->(dbSkip())
			EndIf
			
			nTotRet:= 0
			aCerts		:=	{}
				
		EndDo
		If !lGera
			MsGAlert("Não será(ão) gerado(s) Resguardo para a parametrização selecionada")
			Return
		EndIf
	Endif  
Endif     

If !Empty(cMsgCert) 
	Aviso(STR0011,cMsgCert,{STR0021})	// "Certificados de Retenção"###
Endif
	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085Exc()
Realiza a exclusao de um resguardo selecionado no mBrowse, a partir das validacoes 
realizadas

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F085Exc()
Local cMsgAlert := ""
Local cMsgValid := ""
Local cPulaLin	:= chr(13) + chr(10)
Local lExclui:=.T.


If ExistBlock("FIS85VLEX")
	lExclui:=ExecBlock("FIS85VLEX",.F.,.F.)
EndIf


                                           
	//Monta a Mensagem de validacao
	cMsgValid := "Este resguardo ja foi transmitido e não pode ser excluido"
    If lExclui .And. (CLE->CLE_STATUS == NAO_TRANSMITIDO .or. ;
    	CLE->CLE_STATUS == NAO_RONDA .or. ;
		CLE->CLE_STATUS == NAO_DGI)

	    //Monta a mensagem de alerta ao usuario
		cMsgAlert := 'Confirma a exclusão do resguardo selecionado ? ' 
		cMsgAlert += 'ATENÇÃO: Este procedimento é irreversivel. Deseja continuar ?' + cPulaLin  + cPulaLin  
		cMsgAlert += 'Serie: ' + alltrim(CLE->CLE_SERIER) + '/ Numro: ' + alltrim(CLE->CLE_NUMREG) + cPulaLin+ cPulaLin
	
		
	  	If Aviso("Exclusão de Resguardo Nro: " + alltrim(CLE->CLE_NUMREG),cMsgAlert,{'Sim','Não'}) == 1
			  	
			//Apaga a CLF (Itens)
			dbSelectArea("CLF")
			CLF->(dbSetOrder(1))
			If CLF->(dbSeek(xFilial('CLE')+CLE->CLE_TPRESG+CLE->CLE_SERIER+CLE->CLE_NUMREG ))
			
				While CLF->(!Eof()) .and. ;
					CLE->CLE_FILIAL == xFilial('CLE') .and. ;
					CLE->CLE_TPRESG == CLF->CLF_TPRESG .and. ;
					CLE->CLE_SERIER == CLF->CLF_SERIER .and. ;
					CLE->CLE_NUMREG == CLF->CLF_NUMREG 
					
					RecLock("CLF",.F.)
					CLF->(dbDelete())
					CLF->(msUnlock())
					
					CLF->(dbSkip())
				EndDo
				CLF->(dbCloseArea())
				
				RecLock('CLE',.F.)
				CLE->(dbDelete())
				CLE->(msUnlock())
				Aviso(STR0011,STR0018,{STR0021})	// "Certificados de Retenção"###		
			Endif
		EndIf
	Else
		MsgStop(cMsgValid)	
	EndIf
		
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085Imp()
Realiza a impressao / reimpressao de um resguardo selecionado no mBrowse

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F085Imp()
Local alCertRet := {}
Local cDescri:=""
SX5->(dbSeek(xFilial("SX5")+"RU"+CLE->CLE_TPRESG))
cDescri:= (X5Descri())

		
		//Seleciona os dados de impressao e armazena em um array
		dbSelectArea('CLF')
		CLF->(dbSetOrder(1))
		If CLF->(dbSeek(xFilial('CLF')+CLE->CLE_TPRESG+CLE->CLE_SERIER+CLE->CLE_NUMREG ))
			While CLF->(!Eof()) .and. ;
				CLF->CLF_FILIAL = xFilial('CLF') .and. ;
				CLF->CLF_TPRESG = CLE->CLE_TPRESG .and. ;
				CLF->CLF_SERIER = CLE->CLE_SERIER .and. ;
				CLF->CLF_NUMREG = CLE->CLE_NUMREG 		
			
				aadd(alCertRet,{CLF->CLF_SERIER,;	// [1]	Numero Certificado
					CLF->CLF_NUMREG,;
					CLE->CLE_DTRESG,;	// [2]	Data Emissao
					CLF->CLF_FORNEC,; // [3]	Codigo do Fornecedor
					CLF->CLF_LOJA ,; // [4]	Loja
					CLF->CLF_TPRESG,;		// [5]	Tipo
					CLF->CLF_NUM,;									// [6]	Numero da fatura
					CLF->CLF_SERIE,;								// [7]	Serie da fatura
				    CLF->CLF_ESPECI,;
					CLF->CLF_BASIM,;                               //bASE iSENTA IRPF
					CLF->CLF_VALIM,;								//Base de calculo da retenção IRPF
					CLF->CLF_ALQIM,;								//Aliquota para o Calculo IRPF					
					CLF->CLF_DTEMDC, ;
					cDescri, ;   // [17] Tipo (C-Cliente\F-Fornecedor)
					CLF->CLF_IMP })
					CLF->(DbSkip())
			EndDo
			
			//Executa a funcao de impressao, passando o array com os dados
			FISR014(alCertRet)
		EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FMarca   ³ Autor ³ Hermes Ferreira       ³ Data ³16/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca ou Desmarca todas as opções existentes no Browse     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMarca                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ llMarc - Variavel logica, recebe o TRUE ao clicar no Marc, ³±±
±±³          ³ e FALSE ao desmarcar.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Marca/Desmarca Todos			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FMarca(llMarc)

	dbSelectArea("TMP1")
	TMP1->(dbGoTop())

	If llMarc
		While TMP1->(!Eof())
			If RecLock("TMP1",.F.)
				Replace TMP1->OK With cpMarca
				MsUnLock()
			EndIf
			TMP1->(dbSkip())
		EndDo
	Else
		While TMP1->(!Eof())
			If RecLock("TMP1",.F.)
				Replace TMP1->OK With Space(2)
				MsUnLock()
			EndIf
			TMP1->(dbSkip())
		EndDo
	EndIf

	TMP1->(dbGoTop())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GerNumCert³ Autor ³ Marcos Kato          ³ Data ³30/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o proximo numero do certificado do imposto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Retorna o numero de certificado e o Numero de Autorizacao  ³±±
±±³          ³ aArray[1] -> Numero Certificado                            ³±±
±±³          ³ aArray[2] -> Numero Autorizacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Equador                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GerNumCert(cImp,nTipo)
Local cImpX5 	:=""
Local aCertRet	:={}
Local aAreaA:= GetArea()
Default cImp:=""                
Default nTipo:=1



aCertRet:={}
//Pega o proximo Numero do Certificado de IR e verifica se a numeracao esta dentro do controle de folios tipo RIR		
	
	
DbSelectArea("SX5")
If dbSeek(xFilial("SX5")+"01"+cImp)
	cImpX5 := (X5Descri())
	cImpX5 := Alltrim(StrZero(VAL(cImpX5)+1,TamSx3("CLE_NUMREG")[1]))
	aAdd(aCertRet,cImp)
	aAdd(aCertRet,cImpX5)							
	If RecLock("SX5",.F.)
		Replace X5_DESCRI	WITH cImpX5
		Replace X5_DESCSPA	WITH cImpX5
		Replace X5_DESCENG	WITH cImpX5
		SX5->(MsUnLock())
	EndIf
Endif 				

RestArea(aAreaA)
If Len(aCertRet)==0
	MsgStop(STR0083 +cImp)
EndIf
Return aCertRet    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna as opcoes disponiveis para utilizacao na mBrowse

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MenuDef()                     
Local aRet	:= {	{ STR0073  , "AxPesqui" 	, 0 , 1,,.F. },; 		// "Pesquisa"
					{ "Visual"  , "F085VISUA" 	, 0 , 2},; 				// "Incluir"
				 	{ STR0074  , "F085Gera" 	, 0 , 3},; 				// "Incluir"
				 	{ STR0076  , "F085Exc"	 	, 0 , 5},; 				// "Excluir"
				 	{ STR0077  , "Fis58Tra" 	, 0 , 6},; 				// "Transmitir"
				 	{ "Anular" , "Fis58Anu" 	, 0 , 6},; 				// "Anular"
				 	{ STR0078  , "F085Imp"  	, 0 , 6},; 				// "Imprimir"
				 	{ STR0079  , "Fis85Sin"  	, 0 , 6},; 			// "Sincronizar"
				 	{ STR0080  , "Fis85Mon"  	, 0 , 6},; 				// "Monitor"
					{ STR0081  , "Fis85imp"  	, 0 , 6},; 				// "Visualizar PDF"
					{ STR0082  , "F085Leg"  	, 0 , 6, ,.F.} }    	// "Legenda"


If ExistBlock("FIS85MNU")
	aRet  := Execblock("FIS85MNU",.F.,.F.,aRet)
EndIf

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085DefLeg
Retorna as definições de legenda da mBrowse da rotina de Resguardos

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F085DefLeg()
Local cRet := ""

	Do Case
		Case CLE->CLE_STATUS = NAO_TRANSMITIDO
			cRet := "BR_VERMELHO"
		Case CLE->CLE_STATUS = TRANSMITIDO
			cRet := "BR_AMARELO"
		Case CLE->CLE_STATUS = AUTORIZADO
			cRet := "BR_VERDE"
		Case CLE->CLE_STATUS = NAO_RONDA
			cRet := "BR_AZUL"		
		Case CLE->CLE_STATUS = NAO_DGI
			cRet := "BR_PRETO"
		Case CLE->CLE_STATUS = ANULADO
			cRet := "BR_PINK"
		Case CLE->CLE_STATUS = ANU_TRANS
			cRet := "BR_MARRON"
		Case CLE->CLE_STATUS = ANU_AUTORIZADA
			cRet := "BR_LARANJA"
		Case CLE->CLE_STATUS = ANU_NAO_AUTOR
			cRet := "BR_VIOLETA"
		Otherwise
			cRet := "BR_VERMELHO"	
	End Case
	
Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F085Leg
Exibe a dialog com as legendas disponiveis na rotina de resguardo

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F085Leg()
BrwLegenda("Resguardos","Legenda",	{	{ "BR_VERMELHO"	,"Não Transmitido/Autorizado"},;
										{ "BR_AMARELO"	,STR0084},;
				   				  		{ "BR_VERDE"	,STR0085},;
				   				  		{ "BR_AZUL"	,STR0086},;
				   				  		{ "BR_PRETO"	,STR0087},;
				   				  		{ "BR_PINK"	,STR0088},;
				   				  		{ "BR_MARRON"	,STR0089},;
				   				  		{ "BR_LARANJA"	,STR0090}})
Return
    


/*Static Function F085CodRet(cTipoNF,cSerie,cDoc,cCodFor,cLojFor)	
Local aCodRet := Array(4)
Local aArea := GetArea()
  */
	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fis58Tra  ºAutor  ³Fernando Bastos     º Data ³  08/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a remessa dos resguados eletronicos                	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uruguai                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fis58Tra(cAlias)   

Local aArea       := GetArea()
Local aPerg       := {}
Local aParam      := {Space(Len(CLE->CLE_SERIER)),Space(Len(CLE->CLE_NUMREG)),Space(Len(CLE->CLE_NUMREG)),"",""}
Local aTexto      := {}

Local cRetorno    := ""
Local cIdEnt      := ""
Local cModalidade := ""
Local cAmbiente   := ""
Local cVersao     := ""
Local cVersaoCTe  := ""
Local cVersaoDpec := ""
Local cMonitorSEF := ""
Local cSugestao   := ""

Local nX          := 0

Local lOk         := .T.
local lRetorno	  := .T.
Local oWs
Local oWizard
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"RES"

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),Len(CLE->CLE_SERIER))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),Len(CLE->CLE_NUMREG))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),Len(CLE->CLE_NUMREG))

	aadd(aPerg,{1,STR0055,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie de Resguardo"  
	aadd(aPerg,{1,STR0056,aParam[02],"",".T.","",".T.",60,.T.}) //"Resguardo inicial"    
	aadd(aPerg,{1,STR0057,aParam[03],"",".T.","",".T.",60,.T.}) //"Resguardo final"     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Default cAmbiente :=""
	If (lOk == .T. .or. lOk == Nil) 
		aadd(aTexto,{})
		aTexto[1] := STR0092
		If !Empty(cSugestao)
			aTexto[1] += CRLF
			aTexto[1] += cSugestao
			aTexto[1] += CRLF
		EndIf			
		aTexto[1] += cMonitorSEF
		
		aadd(aTexto,{})
	
		DEFINE WIZARD oWizard ;
			TITLE  STR0051;  //"Asistente de transmision de Resguardo";     					    //STR0051     
			HEADER STR0052;  //"Atencion";  	 													//STR0052     
			MESSAGE STR0053; //"Siga atentamente los pasos para la configuracion de la Resguardo."; //STR0053     
			TEXT aTexto[1] ;
			NEXT {|| .T.} ;
			FINISH {||.T.}
	
		CREATE PANEL oWizard  ;
			HEADER STR0054; //"Asistente de transmision de Resguardo" ;    							//STR0054 
			MESSAGE ""	;
			BACK {|| .T.} ;
			NEXT {|| ParamSave(cParNfeRem,aPerg,"1"),Processa({|lEnd| cRetorno := Fis85Gera(cAlias,aParam[1],aParam[2],aParam[3])}),aTexto[02]:= cRetorno,.T.} ;
			PANEL
	    ParamBox(aPerg,"Resguardo",@aParam,,,,,,oWizard:oMPanel[2],cParNfeRem,.T.,.T.)
	
		CREATE PANEL oWizard  ;
			HEADER "Asistente de transmision de Resguardo";     //STR0054    //STR0088
			MESSAGE "";
			BACK {|| .T.} ;
			FINISH {|| .T.} ;
			PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
		ACTIVATE WIZARD oWizard CENTERED
	EndIf
	lRetorno := lOk	

RestArea(aArea)
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis58Anu
Funcao que gera o arquivo de anulacao do resguardo

@author  Microsiga Protheus
@version P10
@since 	 28/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis58Anu()
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   Verifica se o resguardo foi autorizado antes de proceder a anulacao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If CLE->CLE_STATUS == AUTORIZADO
		If Aviso(STR0093,STR0094,{STR0095,STR0096}) == 1
			RecLock("CLE",.F.)
			CLE->CLE_STATUS := ANULADO
			CLE->CLE_DTTRAN := Date()
			CLE->CLE_HRTRAN := Time()
			CLE->CLE_OBS := STR0097
			CLE->(msUnlock())		     
			MsgInfo(STR0097)
		EndIf
	Else
		MsgAlert(STR0098)
	EndIf	
Return
         	
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis85Gera
Rotina de remessa do Resguardo

@author  Microsiga Protheus
@version P10
@since 	 28/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis85Gera(cAlias,cSerie,cNotaIni,cNotaFim,cRetorno)

Local cAliasCLE  := ""
Local nX		 := 0
Local nNFes		 := 0	

Local aNotas	 := {}
Local aXML		 := {}
Local lRetorno   := .F.

Local cNotTrans 	:= NAO_TRANSMITIDO
Local cNotAutRonda 	:= NAO_RONDA
Local cNotAutDGI 	:= NAO_DGI
Local cAnulado 		:= ANULADO

Default cSerie   := ""      
Default cNotaIni := ""
Default cNotaFim := ""
Default cAlias 	 := 'CLE'

	cAliasCLE := GetNextAlias()
	BeginSql Alias cAliasCLE
		
	COLUMN CLE_DTRESG AS DATE
	
	SELECT CLE_FILIAL,CLE_TPRESG,CLE_SERIER,CLE_NUMREG,
	       CLE_FORNEC,CLE_LOJA,CLE_DTRESG,CLE_MDDOC,
	       CLE_OBS,CLE_DTTRAN,CLE_HRTRAN,CLE_PROT,
	       CLE_STATUS,CLE_VALIMP,CLE_PROT,CLE_STATUS,
	       CLE_CAE,CLE_SERCAE,CLE_SITNOT 
	       FROM %Table:CLE% CLE WHERE
		   	CLE.CLE_FILIAL = %xFilial:CLE% AND				
		   	CLE.CLE_SERIER = %Exp:cSerie% AND 
		   	CLE.CLE_NUMREG >= %Exp:cNotaIni% AND 
		   	CLE.CLE_NUMREG <= %Exp:cNotaFim% AND 
		   		(CLE.CLE_STATUS = %Exp:cNotTrans% OR	//Nao transmitidos
		   		CLE.CLE_STATUS = %Exp:cNotAutRonda% OR		//Nao Autorizados RondaNet
		   		CLE.CLE_STATUS = %Exp:cNotAutDGI% OR		//Nao Autorizados DGI
		   		CLE.CLE_STATUS = %Exp:cAnulado%) AND	//Anulados nao transmitidos
		   	CLE.%notdel%
	EndSql
          
 	While !Eof() .And. xFilial("CLE") == (cAliasCLE)->CLE_FILIAL .And.;
		(cAliasCLE)->CLE_SERIER == cSerie .And.;
		(cAliasCLE)->CLE_NUMREG >= cNotaIni .And.;    
		(cAliasCLE)->CLE_NUMREG <= cNotaFim
	    
		If (cAliasCLE)->CLE_STATUS <> AUTORIZADO

			IncProc(STR0024+(cAliasCLE)->CLE_NUMREG)  //STR0024 "Preparando nota: "   

			aadd(aNotas,{})	
			nX := Len(aNotas)
			aadd(aNotas[nX],(cAliasCLE)->CLE_NUMREG)
			aadd(aNotas[nX],(cAliasCLE)->CLE_SERIER)			
			aadd(aNotas[nX],(cAliasCLE)->CLE_TPRESG)
			aadd(aNotas[nX],(cAliasCLE)->CLE_FORNEC)
			aadd(aNotas[nX],(cAliasCLE)->CLE_LOJA)			
			aadd(aNotas[nX],(cAliasCLE)->CLE_DTRESG)
			aadd(aNotas[nX],(cAliasCLE)->CLE_STATUS)
			
		EndIf
		(cAliasCLE)->(dbSkip())
	EndDo
	
	For nX := 1 To Len(aNotas)  
		//Gera o conteudo da mensagem XML
	    aXML := ExecBlock("FISA085XML",.F.,.F.,{aNotas[nX][1],aNotas[nX][2],aNotas[nX][3],aNotas[nX][4],aNotas[nX][5],aNotas[nX][6]}) 
	    
	    //Gera o arquivo XML em disco
		//lRetorno := F85GerArq(aXML)
		lRetorno := F057Trans(aXML,TYPE_RESG)
		
		//Atualiza Status da CLE
		If lRetorno
			dbSelectArea('CLE')
			CLE->(dbSetOrder(1))
			If CLE->(dbSeek(xFilial('CLE')+aNotas[nX,3]+aNotas[nX,2]+aNotas[nX,1]))
			     //parei aqui 
			     RecLock("CLE",.F.)
			     If CLE->CLE_STATUS == ANULADO
			     	//Resguardo de Anulação
					CLE->CLE_STATUS := ANU_TRANS
			     Else
			     	//Resguardo Comum
					CLE->CLE_STATUS := TRANSMITIDO
			     EndIf			     
			     CLE->CLE_DTTRAN := Date()
			     CLE->CLE_HRTRAN := Time()
			     CLE->CLE_OBS := "Documento transmitido, aguardando autorização"
			     CLE->(msUnlock())
			EndIf
		EndIf
		
		//Contador de documentos transmitidos
		nNFes++	
	Next nX
				
	If lRetorno
	    cRetorno := STR0066+AllTrim(Str(nNFes,18))+" Resguardo(s)"  //###"Foram transmitidas"
	Else
		cRetorno := STR0067 //###"Error en transmisión" 
	EndIf

Return (cRetorno)
 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F85GerArq   ºAutor  ³Fernando Bastos     º Data ³25/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o arquivo xml                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nfe Uruguai                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function F85GerArq(aDadosXML)
	Local cDirArq  := GetNewPar("MV_AENVIAR") //IIF(aDadosXML[2],GetNewPar("MV_AENVTKM"),GetNewPar("MV_AENVIAR"))
	Local cXML     := aDadosXML[1]
	Local cArqDest := ""
	Local nHandle  := 0
	Local lGerou   := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aDados[1] = String do xml (caracter)            ³
	//³aDados[2] = Tk menores (lógico)                 ³
	//³aDados[3] = Codigo da DGI (caracter)            ³
	//³aDados[4] = Serie (caracter)                    ³
	//³aDados[5] = Numero do Comprovante CFE (caracter)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄa¿
	//³Geracao do nome do arquivo conforme a DGI                  ³
	//³                                                           ³
	//³Si numera el el cliente: nnnAAmmmmmmmGGG.xxx               ³
	//³nnn = Cod DGI de Tipo de CFE                               ³
	//³AA = Nro de Serie                                          ³
	//³mmmmmmm = Nro de CFE                                       ³
	//³xxx = xml para formato DGI o txt para formatos Rondanet    ³
	//³GGG = identificador del generador de comprobantes,         ³
	//³para cuando hay mas de un ERP/sistema generando            ³
	//³comprobantes (puede ser de 1 a 3 caracteres alfanuméricos).³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÙ 

	cArqDest := cDirArq+aDadosXML[3]+lower(Alltrim(aDadosXML[4]))+aDadosXML[5]+".xml" 
	nHandle := FCreate(cArqDest,,,.F.,3)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se é possível criar o arquivo, ³
	//³caso contrário apresenta os erros       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If nHandle <> -1   
		FWrite(nHandle,cXml)
		FClose(nHandle) 
		lGerou := .T.
	Else 	
		Alert('Error al crear archivo:' + Alltrim(Str(Ferror())))        
		lGerou := .F.
	EndIf  
	
Return lGerou 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis85Sin()
Sincroniza os documentos de resguardo

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis85Sin()
	Local cSincro := "sincf085.lck"
	Local nHandle := 0
	Local lIntByFile 	:= GetNewPar("MV_RONDATP",.T.)

	//Cria lock no semaforo para evitar mais de uma sincronizacao simultanea	
	nHandle := F057Lock(cSincro,.F.)
	If nHandle <> -1
		If lIntByFile		
			MsgRun( STR0058 ,, {||	SincByFile() } )
		Else
			MsgRun( STR0058 ,, {||	SincByWs() } )		
		EndIf
	Else 
		MsgAlert(STR0059) //STR0059  "Proceso ya se está ejecutando"
	Endif

	//Libera semaforo	
	nHandle := F057Lock(cSincro,.T.)
	
   	//Alivia memoria
	DelClassIntF()      
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SincByWs
Realiza a sincronizacao de documentos por meio do WebServices RondaNet

@author  Microsiga Protheus
@version P10
@since 	 17/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SincByWs()
	Local cQuery 	:= ""
	Local cDescRej	:= ""
	Local aArea		:= (Alias())->(GetArea())
	Local oWsRonda	:= Nil
	Local cSerCae	:= ""
	Local cNroCae	:= ""
	Local cArq64	:= ""
	Local cCodDoc   := "182"

	dbSelectArea('CLE')
	If FindFunction('U_RFatC01')			
                          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona os documentos pendentes de processamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT CLE.CLE_SERIER SERIE, CLE.CLE_NUMREG DOC, CLE.CLE_SERCAE SERCAE, CLE.CLE_CAE NROCAE, "
		cQuery += " CLE.CLE_STATUS STAT, CLE.R_E_C_N_O_ RECN " 
		cQuery += " FROM " + RetSqlName("CLE") + " CLE "
		cQuery += " WHERE CLE.CLE_FILIAL = '" + xFilial('CLE') + "'"
		cQuery += " 	AND (CLE.CLE_STATUS = " + alltrim(TRANSMITIDO) + " OR CLE.CLE_STATUS = " + alltrim(ANU_TRANS) + ")"
		cQuery += " 	AND CLE.D_E_L_E_T_ = ' ' "
		iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRY", .F., .T.)	
		While QRY->(!Eof())
            	  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³1* - Verifica se possui CAE. Se nao tiver, entao busca por meio do nro Interno³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If Empty(QRY->SERCAE) .or. Empty(QRY->NROCAE) 
		    
		    	cArq64 := ""                                                                    			  		
				cNroCae := "" 
				cSerCae := ""   
				
				//oWsRonda := WSRondanet():New()
				//oWsRonda:_URL := GetNewPar("MV_IPWSRON","")
				cWsUser			:= GetNewPar("MV_URUUSER","")
				cWsPass			:= GetNewPar("MV_URUPASW","")
				//Local cWsVersao		:= GetNewPar("MV_URUVWS","3.1")	//Versao 2.0 (antiga) ou Versao 3.1 (nova)
				oWsRonda := WSRondanetService():New()
				oWsRonda:_URL 							:= GetNewPar("MV_IPWSRON","")
				oWsRonda:crutEmisor 					:= Alltrim(SM0->M0_CGC)
				oWsRonda:cusuario 	   					:= cWsUser
				oWsRonda:cpassword 					:= cWsPass
				oWsRonda:ntipoComprobante			:= val(cCodDoc)					
				oWsRonda:cserieinterno			:= alltrim(QRY->SERIE)//Alltrim(QRY->SERIE)  //QRY->SERCAE //cSerCae
				oWsRonda:nnumerointerno	:= val(QRY->DOC)     
								
				If oWsRonda:obtenerNumeracionComprobante()
		
						If ValType(oWsRonda:cReturn) == "C" .and. !Empty(oWsRonda:cReturn)
							CAVISO := ''
							CWARNING:=''
							oPDFt := XMLParser(oWsRonda:cReturn,'_',@cAviso,@cWarning)
						//	cArq64 := OPDFT:_RESPUESTA_WS:_DESCRIPCION:TEXT                                                                    			  		
							cNroCae := OPDFT:_RESPUESTA_WS:_NUMERO:TEXT 
							cSerCae := OPDFT:_RESPUESTA_WS:_SERIE:TEXT    
						eNDiF
        	    		        	    		
					 	CLE->(dbGoTo(QRY->RECN))
					 	
					 	If Empty(QRY->SERCAE) .or. Empty(QRY->NROCAE)
					 		RecLock('CLE',.F.)
					 		CLE->CLE_SERCAE := cSerCae
					 		CLE->CLE_CAE := cNroCae
					 		CLE->(msUnlock())
						EndIf
				eNDiF

	
	        Elseif !Empty(QRY->SERCAE) .OR. !Empty(QRY->NROCAE) 	
	        
	        	cSerCae :=	QRY->SERCAE
 				cNroCae :=	QRY->NROCAE
	        
			EndIf	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³2* Atualiza o status do documento de acordo com os dados recebidos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 				
 			
 			cDescRej := alltrim(U_RFatC01(alltrim(SM0->M0_CGC),val(cCodDoc),cSerCae,val(cNroCae)))
			If !Empty(cDescRej)			 	
			 	CLE->(dbGoTo(QRY->RECN))
			 	RecLock('CLE',.F.)
			 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
				 	If CLE->CLE_STATUS = TRANSMITIDO
				 		CLE->CLE_STATUS := NAO_DGI
				 	Else
					 	CLE->CLE_STATUS := ANU_NAO_AUTOR
				 	EndIf
				ElseIf upper(substr(cDescRej,1,2)) == "AE"
					If CLE->CLE_STATUS = TRANSMITIDO
						CLE->CLE_STATUS := AUTORIZADO
					Else
						CLE->CLE_STATUS := ANU_AUTORIZADA
					EndIf
				EndIf
				CLE->CLE_SITNOT := cDescRej
			 	CLE->(msUnlock())
			EndIf
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³3* Atualiza o documento (PDF) na base do Protheus a partir do Base64 enviado pelo WS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If  Empty(CLE->CLE_ARQPDF)
			
				cWsUser			:= GetNewPar("MV_URUUSER","")
				cWsPass			:= GetNewPar("MV_URUPASW","")
				oWsRonda := WSRondanetService():New()
				oWsRonda:_URL 							:= GetNewPar("MV_IPWSRON","")
				oWsRonda:crutEmisor 					:= Alltrim(SM0->M0_CGC)
				oWsRonda:cusuario 	   					:= cWsUser
				oWsRonda:cpassword 				  		:= cWsPass
				oWsRonda:ntipoComprobante				:= val(cCodDoc)					
   				oWsRonda:cserie							:= cSerCae
				oWsRonda:nnumeroComprobante				:= val(cNroCae)
				//oWsRonda:cserie							:= alltrim(QRY->SERCAE)//Alltrim(QRY->SERIE)  //QRY->SERCAE //cSerCae
				//oWsRonda:nnumeroComprobante	:= val(QRY->NROCAE)
								
				If oWsRonda:obtenerRepresentacionImpresa()
			
					If ValType(oWsRonda:cReturn) == "C" .and. !Empty(oWsRonda:cReturn)
						CAVISO := ''
						CWARNING:=''
						oPDFt := XMLParser(oWsRonda:cReturn,'_',@cAviso,@cWarning)
						cArq64 := OPDFT:_RESPUESTA_WS:_DESCRIPCION:TEXT                                                                    			  		
						cNroCae := OPDFT:_RESPUESTA_WS:_NUMERO:TEXT 
						cSerCae := OPDFT:_RESPUESTA_WS:_SERIE:TEXT    
	
	        	    		        	    		
					 	CLE->(dbGoTo(QRY->RECN))
						 	
						If Empty(CLE->CLE_ARQPDF)
							RecLock('CLE',.F.)
							CLE->CLE_ARQPDF := cArq64
							CLE->(msUnlock())
						EndIf
											
					Else
						MsgStop('Retorno não esperado pelo WS Rondanet')
					EndIf
				EndIf
			Else
				cSerCae := QRY->SERCAE
				cNroCae := QRY->NROCAE
			EndIf   
		   
		   
		   /* oWsRonda := WSRondanet():New()
			oWsRonda:_URL := GetNewPar("MV_IPWSRON","")
		  	If oWsRonda:getDocument(alltrim(SM0->M0_CGC),val(cCodDoc),cSerCae,val(cNroCae))
		  	    cArq64 := oWsRonda:cReturn

			 	CLE->(dbGoTo(QRY->RECN))
			 	RecLock('CLE',.F.)
			 	CLE->CLE_ARQPDF := cArq64			 	
			 	CLE->(msUnlock())
			EndIf
			*/
			//Zera variaveis e vai para o proximo registro
			cSerCae := ""
			cNroCae := ""
			cArq64 := ""		
			QRY->(dbSkip())
		EndDo
		QRY->(dbCloseArea()) 
	EndIf

	RestArea(aArea)	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SincByFile
Realiza a sincronizacao de documentos por meio da troca de arquivos com o aplicativo RondaNet

@author  Microsiga Protheus
@version P10
@since 	 17/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SincByFile()
Local cError    	:= ""
Local cWarning  	:= ""
Local cPathRej 		:= GETMV("MV_NOENVIA") 
Local cPathCon 		:= GETMV("MV_CONTROL")
Local cPathImp		:= GETMV("MV_URUIMP")
Local cNomImp       := ""
Local cNomImpPDF	:= ""
Local cArqTxt		:= ""
Local cNunNota		:= ""
Local cSerNota      := ""
Local cNunNotaRej	:= ""
Local cSerNotaRej   := ""                            		
Local cMotRej		:= ""
Local cNunDGI		:= ""
Local cSerDGI		:= ""
Local cTipoCFE		:= "" 
Local cArq 			:= "" 
Local cArqCom		:= ""
Local cExiNota		:= ""

Local aXmlRej 		:={}
Local aXmlRejTxt	:={}
Local aXmlCon		:={}
Local aPdfImp		:={}

Local nY			:= 0
Local nZ			:= 0
Local nJ			:= 0
Local nJX			:= 0
Local nW			:= 0   
Local nI			:= 0                    
Local nQuaXml		:= 0
Local nHandle		:= 0
Local nTam			:= 0
Local nHanimp    	:= 0

Private oXmlRec
Private oXmlRej
Private oXmlCon 

If !Empty(cPathRej) .and. !Empty(cPathCon) .and. !Empty(cPathImp)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      OBTEM OS ARQUIVOS A SEREM PROCESSADOS      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aXmlRej  	:= directory(cPathRej+"*.xml",,,.F.)				// ----- Pega o XML da pasta NoEnviados
	aXmlRejTxt  := directory(cPathRej+"*.txt",,,.F.)				// ----- Pega o TXT da pasta NoEnviados
	aXmlCon		:= directory(cPathCon+"*.xml",,,.F.)				// ----- Pega o XML da pasta Control
	aPdfImp		:= directory(cPathImp+"*.*",,,.F.)					// ----- Pega todos arquivos da pasta Impresion
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³        PROCESSA O DIRETORIO DE AUTORIZADOS        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nJ :=1 To len (aXmlCon)		

		//Parseia o XML 
		oXmlCon := MyParserFile(cPathCon + aXmlCon[nJ,1], "_", @cError, @cWarning,,.F.)
		If (Empty(cError) .and. empty(cWarning))
		    If Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE")<>"U" .OR. Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE")=="A"
				
				If Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE")=="A" 
			   		oXmlCon := oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE 
				Else 
			   		oXmlCon := {oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE} 
				EndIf
			   	
				//Processa as notas que estao dentro do XML
			   	For nJX := 1 To Len(oXmlCon)
					If ( Type("oXmlCon[nJX]:_NROEMPRESA:TEXT") <> "A" )					
						cNunNota := oXmlCon[nJX]:_NROEMPRESA:TEXT
					EndIf 			 
					If ( Type("oXmlCon[nJX]:_SERIEEMPRESA:TEXT") <> "A" )
						cSerNota := oXmlCon[nJX]:_SERIEEMPRESA:TEXT 
	     			EndIf
	     			If ( Type("oXmlCon[nJX]:_TIPOCFE:TEXT") <> "A" )  
						cTipoCFE := oXmlCon[nJX]:_TIPOCFE:TEXT
	     			EndIf                   
					If ( Type("oXmlCon[nJX]:_NRODGI:TEXT") <> "A" )
	                   	cNunDGI	:= oXmlCon[nJX]:_NRODGI:TEXT 
	       			EndIf
	       		If ( Type("oXmlCon[nJX]:_SERIEDGI:TEXT") <> "A" )
						cSerDGI := oXmlCon[nJX]:_SERIEDGI:TEXT 
	      			EndIf
	      			
	      			      							
					If !Empty(cNunNota) .And. !Empty(cSerNota) .And. !Empty(cTipoCFE) .And. !Empty(cNunDGI) .And. !Empty(cSerDGI)
						
						//Busca o resguardo na CLE
					 	dbSelectArea("CLE")                      		
						CLE->(dbSetOrder(4))
					  	If CLE->(dbSeek(xFilial("CLE") + PADR(cSerNota,len(CLE->CLE_SERIER)) + STRZERO(val(cNunNota),len(CLE->CLE_NUMREG))))					 
							
							//Verifica se é necessario processar o item							
							If IsProcess()
								
								//Pesquisa se a nota ja possui PDF Disponivel
								//Se possuir, le seu conteudo BINARIO para gravar na CLE
								If Len(aPdfImp) > 0
									cNomImp := cTipoCFE+Alltrim(cSerDGI)+cNunDGI
									nPos := aScan(aPdfImp,{|x| cNomImp $ x[1]})
									If nPos > 0
										cNomImpPDF := aPdfImp[nPos,1]															
										nHanimp := FOpen(cPathImp+aPdfImp[nPos,1],,0,.F.)
									   	If nHanimp > -1
										   	nTam 	:= Fseek(nHanimp,0,FS_END)
										   	If nTam <= 950000 
										 		FSeek(nHanimp,0,FS_SET)
										 		nI := 1 
												cArqCom := ""
										 		While nI <= nTam
													FRead(nHanimp,@cArq,NBYTES_READ) 
													cArqCom += cArq
													cArq := ""			
													nI := nI + NBYTES_READ
												EndDo
												FClose(nHanimp)
											EndIf
										Endif
									EndIf
									
									//Atualiza os dados nas tabelas do Protheus (CLE)												
									RecLock("CLE",.F.)
									//CLE->CLE_STATUS := AUTORIZADO
									CLE->CLE_CAE	:= cNunDGI								
									CLE->CLE_SERCAE := cSerDGI
									CLE->CLE_SITNOT := STR0062										
									CLE->CLE_ARQPDF := Encode64(cArqcom)
									CLE->(MsUnLock())
                                    
									//Reseta Variaiveis
									cNunNota   := ""
									cSerNota   := ""
									cTipoCFE   := ""
									cNunDGI    := ""
									cSerDGI	   := ""	  									
									cNomImp    := ""
									cNomImpPDF := "" 
									cArqCom	   := ""
								Endif						
							Endif
						EndIf
					EndIf
				Next nJX 					                               		
			EndIf					                                                                                          	
		Endif													
    Next nJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³         PROCESSA O DIRETORIO DE REJEICOES         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nY :=1 To len(aXmlRej)			
	  	//Parseia o XML para obter informacoes
		oXmlRej := MyParserFile(cPathRej + aXmlRej[nY,1], "_", @cError, @cWarning,,.F.)	
		
		//Coleta o Numero e a Serie do documento dentro do XML parseado					
		If Empty(cError) .and. empty(cWarning) 						
			//Tipo Resguardo						
			If ( Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ERESG:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT") <> "U" )
				cNunNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ERESG:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT
			EndIf							
			If Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ERESG:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT") <> "U"
				cSerNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ERESG:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT
			Endif
		EndIf

		dbSelectArea("CLE")                      		
		CLE->(dbSetOrder(4))
	  	If !Empty(cNunNotaRej) .And. !Empty(cSerNotaRej) .and. CLE->(dbSeek(xFilial("CLE")+PADR(cSerNotaRej,len(CLE->CLE_SERIER))+STRZERO(val(cNunNotaRej),len(SF3->F3_NFISCAL))))

			//Verirfica se possui o arquivo TXT desta nota no diretorio de TXTs			
			If Len(aXmlRejTxt) > 0  				
				nPos := aScan(aXmlRejTxt,{|X| substr(aXmlRej[nY,1],1,len(aXmlRej[nY,1])-4) $ x[1] })
				If nPos > 1											
					lNotTxt := .F.
					nHandle := FOpen(cPathRej+aXmlRejTxt[nPos,1],,0,.F.)
					FRead(nHandle,@cArqTxt,512000)
					Fclose(nHandle)					
				EndIf				
			EndIf
			
			//Atualiza os dados no protheus - Tabela CLE
  			RecLock("CLE",.F.)
			CLE->CLE_SITNOT  := cArqTxt
			CLE->CLE_STATUS  := NAO_RONDA
			CLE->(MsUnLock())
		Endif
		
		cSerNotaRej:= "" 
		cNunNotaRej:= ""				 		
		oXmlRej	   := NIL
		cArqTxt	   := ""
	Next nY	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³    Chama o WS para as notas da SF1 e SF2 que tem CAE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetDescFromWS()	
Else
	Aviso(STR0099,STR0100,{"Ok"})
EndIf    
                                                      																							
RETURN 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fis85Mon  ºAutor  ³Fernando Bastos     º Data ³  21/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monitora as notas recepcionadas pelo RondaNet              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uruguai                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Function Fis85Mon(cAlias) 

Local cIdEnt   := ""
Local aPerg    := {}
Local aParam   := {Space(Len(CLE->CLE_SERIER)),Space(Len(CLE->CLE_NUMREG)),Space(Len(CLE->CLE_NUMREG)),"",""}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFERE"//SPEDNFEREM
Local lOK        := .F.

Default cAlias := 'SF2'

aadd(aPerg,{1,STR0055,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie de Resguardo"    
aadd(aPerg,{1,STR0056,aParam[02],"",".T.","",".T.",60,.T.}) //"Nota fiscal inicial"    
aadd(aPerg,{1,STR0057,aParam[03],"",".T.","",".T.",60,.T.}) //"Resguardo inicial"        
aadd(aPerg,{1,STR0064,dDataBase,"",".T.","",".T.",30,.F.})  //"fecha Inicial"		    
aadd(aPerg,{1,STR0065,dDataBase,"",".T.","",".T.",30,.F.})	//"fecha Final"				   


aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])
aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])

lOK      := ParamBox(aPerg,"Resguardo",@aParam,,,,,,,cParNfeRem,.T.,.T.)
cSerie   := aParam[01] 
cNotaIni := aParam[02] 
cNotaFim :=	aParam[03]
cDataIni := aParam[04] 
cDataFim :=	aParam[05]

If (lOK)
	aListBox := ResMonitor(cAlias,cSerie,cNotaIni,cNotaFim,cDataIni,cDataFim)
	If !Empty(aListBox)
		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )
	
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
								
		DEFINE MSDIALOG oDlg TITLE "Resgardo" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
		
		@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0068,STR0002,STR0069,STR0070,STR0071,STR0072; //"Resguardo"###"Serie"###"Data"###CAE###Serie CAE###"Recomendação"   /// STR0132,STR0128,STR0133,STR0137,STR0134,STR0002
			SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
		oListBox:SetArray( aListBox )
		oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4],aListBox[ oListBox:nAT,5],aListBox[ oListBox:nAT,6]} }
		
		@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"  STR0131
		ACTIVATE MSDIALOG oDlg
	EndIf
EndIf
Return                                                                                
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ResMonitor ºAutor  ³Fernando Bastos   º Data ³  21/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Separa todos os itens que serao apresentados no monitor   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida Uruguai                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ResMonitor(cAlias,cSerie,cNotaIni,cNotaFim,cDataIni,cDataFim)
                                                                                                              
Local cAliasCLE  := "cAliasCLE"  
Local aNotas	 := {}

Default cAlias 	 := 'CLE'
Default cSerie 	 := ""
Default cNotaIni := ""
Default cNotaFim := ""
Default cDataIni := ""
Default cDataFim := ""

dbSelectArea("CLE")
dbSetOrder(1)                    	
	#IFDEF TOP
		BeginSql Alias cAliasCLE

		COLUMN CLE_DTRESG AS DATE

		SELECT CLE_FILIAL,CLE_TPRESG,CLE_SERIER,CLE_NUMREG,
		       CLE_FORNEC,CLE_LOJA,CLE_DTRESG,CLE_MDDOC,
		       CLE_OBS,CLE_DTTRAN,CLE_HRTRAN,CLE_PROT,
		       CLE_STATUS,CLE_IMP,CLE_VALIMP,
		       CLE_PROT,CLE_STATUS,CLE_CAE,CLE_SERCAE,
		       CLE_SITNOT FROM %Table:CLE% CLE WHERE
			   CLE.CLE_FILIAL = %xFilial:CLE% AND
			   CLE.CLE_SERIER = %Exp:cSerie% AND 
			   CLE.CLE_NUMREG >= %Exp:cNotaIni% AND 
			   CLE.CLE_NUMREG <= %Exp:cNotaFim% AND 
			   CLE.CLE_DTRESG >= %Exp:cDataIni% AND 
			   CLE.CLE_DTRESG <= %Exp:cDataFim% AND  
			   CLE.%notdel%
		EndSql

	#ELSE
		MsSeek(xFilial("CLE")+cSerie+cSerie+cNotaIni,.T.)
	#ENDIF
	
 	While !Eof() .And. xFilial("CLE") == (cAliasCLE)->CLE_FILIAL .And.;
		(cAliasCLE)->CLE_SERIER == cSerie .And.;
		(cAliasCLE)->CLE_NUMREG >= cNotaIni .And.;    
		(cAliasCLE)->CLE_NUMREG <= cNotaFim .And.;
		(cAliasCLE)->CLE_DTRESG >= cDataIni .And.;
		(cAliasCLE)->CLE_DTRESG <= cDataFim
		
		aadd(aNotas,{})	
		nX := Len(aNotas)
			aadd(aNotas[nX],(cAliasCLE)->CLE_NUMREG)
			aadd(aNotas[nX],(cAliasCLE)->CLE_SERIER)
			aadd(aNotas[nX],(cAliasCLE)->CLE_DTRESG)
			aadd(aNotas[nX],(cAliasCLE)->CLE_CAE)
			aadd(aNotas[nX],(cAliasCLE)->CLE_SERCAE)
			aadd(aNotas[nX],(cAliasCLE)->CLE_SITNOT)				
		dbSkip()		
	EndDo
	dbCloseArea()	
Return(aNotas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fis85imp  ºAutor  ³Fernando Bastos     º Data ³  27/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza o PDF do Resguardo pelo RondaNet            	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uruguai                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß   
*/          
Function Fis85imp(cAlias)
 
Local cArqCom	:= ""
Local cNunNota	:= CLE->CLE_NUMREG
Local cSerNota 	:= CLE->CLE_SERIER 
Local cPathImp  := GetTempPath()
Local nHandle   := 0

 	DbSelectArea("CLE")                      		
	DbSetOrder(4)
  	If dbSeek(xFilial("CLE")+PADR(cSerNota,len(CLE->CLE_SERIER))+STRZERO(val(cNunNota),len(CLE->CLE_NUMREG)))
		cArqCom := Decode64(CLE->CLE_ARQPDF)  					 
	Endif  
	If !Empty (cArqCom)	
		nHandle := FCreate(cPathImp+LOWER(Alltrim(cSerNota))+Alltrim(cNunNota)+".pdf",,2,.F.)
		FWrite(nHandle,cArqCom)	
		Sleep(1000)
		FClose(nHandle)
		ShellExecute("Open",cPathImp+LOWER(Alltrim(cSerNota))+Alltrim(cNunNota)+".pdf","",cPathImp, 1 )
	Else
		MsgInfo(STR0101)   //Arquivo PDF não encontrado
	Endif
Return              

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyParserFile
Funcao alternativa para copia de arquivo para uso exclusivo em contornos paliativos

@param cOrigem	- Path de Origem
	   cDestino	- Path Destino

@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MyParserFile(cPath,cReplace,cError,cWarning,nCompat,lCase)
	Local lTemp 	:= .F.
	Local lAbsolut	:= .F.
	Local cFileName := ""
	Local cDestino	:= "\"
	Local aAux 		:= {} 
	Local oXML		:= Nil
	
	If IsSrvUnix()
		//S.O Linux
	    //Falta Implementar!!!
	    cPath := alltrim(cPath)
	    oXML := XmlParserFile(substr(cPath,2,len(cPath)-1),cReplace,@cError,@cWarning,,lCase)
	Else
		//S.O Windows
		//Verifica se o path eh absoluto ou relativo (a partir do rootPath.)
		//Se for absoluto, faz uma copia temporaria para o RootPath
		//Funcao XMLParserFile tem limitação para trabalhar apenas sobre o RootPath
		lAbsolut := ":" $ cPath
		If lAbsolut
			lTemp := .T.
			aAux := StrTokArr(cPath,"\")
			cFileName := aAux[len(aAux)]
			cDestino := "\" + cFileName
			
			//Cria copia temporaria
			MyCopyFile(cPath,cDestino)
			
			//Faz o Parser sobre a copia temporaria
			oXML := XmlParserFile(cDestino,cReplace,@cError,@cWarning,,lCase)
	
			//Elimina a copia temporaria
			FErase(cDestino)
		Else
		    //Se path ja eh relativo, apenas faz o parser!
		    oXML := XmlParserFile(cPath,cReplace,@cError,@cWarning,,lCase)
		EndIf
	EndIf

Return oXML

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyCopyFile
Funcao alternativa para copia de arquivo para uso exclusivo em contornos paliativos

@param cOrigem	- Path de Origem
	   cDestino	- Path Destino

@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MyCopyFile(cOrigem,cDestino)
Local nHdlOri 	 := 0
Local nHdlDest   := 0
Local cBuffer 	 := ""
Local lGmb	     := .T.
Default cOrigem  := ""
Default cDestino := ""
    
	//Quando a tecnologia preparar a funcao __CopyFile para caseSensitive, alterar a variavel lGmb para .F.
	If lGmb 
		If !Empty(cOrigem) .and. !Empty(cDestino)
			//Abro o arquivo de origem e gravo seu conteudo em buffer
			nHdlOri := FOpen(cOrigem,,3,.F.)
			If nHdlOri > -1
				FRead(nHdlOri,@cBuffer,921600)
				FClose(nHdlOri)
			
				//Gravo o arquivo de destino
				nHdlDest := FCreate(cDestino,,0,.T.,3)
				If nHdlDest <> -1				
					FWrite(nHdlDest,cBuffer)
					Sleep(200)
			        FClose(nHdlDest)
			   	EndIf			   	
		   	EndIf
		EndIf
	Else
		__CopyFile(cOrigem,cDestino)			
	EndIf
Return

//Atualiza status de cancelamento
Function FIS85AtCan(cTipo,cSerie,cnumResg)

dbSelectArea('CLE')
CLE->(dbSetOrder(1))
If CLE->(dbSeek(xFilial('CLE')+cTipo+cSerie+cnumResg))
	While  CLE->(!Eof()).And. (CLE->(xFilial('CLE')+cTipo+cSerie+cnumResg)==CLE->CLE_FILIAL+CLE->CLE_TPRESG+CLE->CLE_SERIER+CLE->CLE_NUMREG)
		CLE->CLE_STATUS := ANU_TRANS
		CLE->CLE_DTTRAN := Date()
		CLE->CLE_HRTRAN := Time()
		CLE->CLE_OBS := STR0102
		CLE->(msUnlock())           
		
		CLE->(DbSkip())
	EndDo	     
	MsgInfo(STR0097)
EndIf

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsProcess
Verifica se vai processar o documento. Se nao tem CAE, processa. 
Se tem, processa apenas se nota é vazio ou se for alguma anulacao

@author  Microsiga Protheus
@version P10
@since 	 23/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function IsProcess()
	Local lRet := .F.
	
	If Empty(CLE->CLE_CAE)
		//Nao tem CAE
		lRet := .T.
	Else
		If CLE->CLE_STATUS == ANU_TRANS
			//Tem CAE mas eh anulacao
			lRet := .T.
		Else
			//Nao eh anulação mas comprovante PDF nao existe na base
			If Empty(CLE->CLE_ARQPDF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
		
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetDescFromWS
Varre a SF1/SF2 em busca de itens transmitidos e sem retorno, para consulta na RondaNet via WS

@author  Microsiga Protheus
@version P10
@since 	 23/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SetDescFromWS()
	Local cQuery := ""
	Local cDescRej := ""
	Local aArea := (Alias())->(GetArea())
	Local cCodDoc := "182"
	
	If FindFunction('U_RFatC01')	
		
		//Seleciona os itens
		cQuery := "SELECT CLE.CLE_SERIER SERIE, CLE.CLE_NUMREG DOC, CLE.CLE_SERCAE SERCAE, CLE.CLE_CAE NROCAE, "
		cQuery += " CLE.CLE_STATUS STAT, CLE.R_E_C_N_O_ RECN " 
		cQuery += " FROM " + RetSqlName("CLE") + " CLE "
		cQuery += " WHERE CLE.CLE_FILIAL = '" + xFilial('CLE') + "'"
		cQuery += " 	AND CLE.CLE_SERCAE <> ' ' "
		cQuery += " 	AND CLE.CLE_CAE <> ' ' "
		cQuery += " 	AND (CLE.CLE_STATUS = " + alltrim(TRANSMITIDO) + " OR CLE.CLE_STATUS = " + alltrim(ANU_TRANS) + ")"
		cQuery += " 	AND CLE.D_E_L_E_T_ = ' ' "
		iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRY", .F., .T.)	
		While QRY->(!Eof())
            	  
			//Faz a busca no WS da RondaNet
 			cDescRej := alltrim(U_RFatC01(SM0->M0_CGC,cCodDoc,QRY->SERCAE,val(QRY->NROCAE)))

			//Atualiza a descricao com a string recebida
			If !Empty(cDescRej)			 	
			 	CLE->(dbGoTo(QRY->RECN))
			 	RecLock('CLE',.F.)
			 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
				 	If CLE->CLE_STATUS = TRANSMITIDO
				 		CLE->CLE_STATUS := NAO_DGI
				 	Else
					 	CLE->CLE_STATUS := ANU_NAO_AUTOR
				 	EndIf
				ElseIf upper(substr(cDescRej,1,2)) == "AE"
					If CLE->CLE_STATUS = TRANSMITIDO
						CLE->CLE_STATUS := AUTORIZADO
					Else
						CLE->CLE_STATUS := ANU_AUTORIZADA
					EndIf
				EndIf
			 	CLE->(msUnlock())
			EndIf
			QRY->(dbSkip())
		EndDo
		QRY->(dbCloseArea()) 
	EndIf

	RestArea(aArea)	
Return


/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |F085VISUA | Autor |Paulo Augusto          | Data |09/10/2014|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Tratamento da Visualizacao                        |
+------------+------------------------------------------------------------+
| Sintaxe    |F085VISUA(ExpC1,ExpN2,ExpN3)                              |
+------------+------------------------------------------------------------+
| Parametros | ExpC1: Alias do arquivo                                    |
|            | ExpN2: Registro do Arquivo                                 |
|            | ExpN3: Opcao da MBrowse                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | Fisa085                                                   |
+------------+------------------------------------------------------------+
/*/
Function F085VISUA(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local lQuery    := .F.
Local cCadastro := OemToAnsi(STR0001) //"Processo de Venda"
Local cQuery    := ""
Local cTrab     := "TRB"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}
//+----------------------------------------------------------------+
//|   Montagem de Variaveis de Memoria                             |
//+----------------------------------------------------------------+
dbSelectArea("CLE")
dbSetOrder(1)
For nCntFor := 1 To FCount()
   M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//+----------------------------------------------------------------+
//|   Montagem do aHeader                                          |
//+----------------------------------------------------------------+
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("CLF")
While ( !Eof() .And. SX3->X3_ARQUIVO == "CLF" )
   If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
      nUsado++
      Aadd(aHeader,{ TRIM(X3Titulo()),;
      TRIM(SX3->X3_CAMPO),;
      SX3->X3_PICTURE,;
      SX3->X3_TAMANHO,;
      SX3->X3_DECIMAL,;
      SX3->X3_VALID,;
      SX3->X3_USADO,;
      SX3->X3_TIPO,;
      SX3->X3_ARQUIVO,;
      SX3->X3_CONTEXT } )
   EndIf
   dbSelectArea("SX3")
   dbSkip()
EndDo
/*
+----------------------------------------------------------------+
|   Montagem do aCols                                            |
+----------------------------------------------------------------+
*/
dbSelectArea("CLF")
dbSetOrder(1)
CLF->(dbSeek(xFilial("CLF")+CLE->CLE_TPRESG+CLE->CLE_SERIER+CLE->CLE_NUMREG))
      bWhile := {|| xFilial("CLF")  == CLF->CLF_FILIAL .And.; 
      CLE->CLE_TPRESG+CLE->CLE_SERIER+CLE->CLE_NUMREG== CLF->CLF_TPRESG+CLF->CLF_SERIER+CLF->CLF_NUMREG }
      
      

While ( !Eof() .And. Eval(bWhile) )
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
		aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
	EndIf
	Next nCntFor
	aCOLS[Len(aCols)][Len(aHeader)+1] := .F.

	dbSkip()
EndDo
aObjects := {} 
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL 
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "" ,"AllwaysTrue","",.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
RestArea(aArea)

Return(.T.)
