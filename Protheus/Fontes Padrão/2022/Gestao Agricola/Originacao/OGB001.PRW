#include "Protheus.ch"

Function OGB001()

Local cDesc1         := "Este programa tem por objetivo ELIMINAR os títulos de previsão "
Local cDesc2         := "nos contratos de Vendas, que já foram eliminados ou Cancelados."
Local cDesc3      	:= "ATENÇÃO.. Antes de confirmar o processo e recomendável fazer uma Cópia de Segurança da tabela SE1"
Local cTitulo        := "Registro de Previsões"
//LocaL oFont1    := TFont():New("Arial",,-12,,.T.) 

Local cAlias		 	:= ""
Private cTamanho     := "P"
Private cNomeProg    := "OGB001" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private cPerg        := "OGB001"
Private wnrel        := "OGB001" // Coloque aqui o nome do arquivo usado para impressao em disco
Private aPerg			:= "OGB001"


MSGALERT("Este programa tem por objetivo ELIMINAR os títulos de previsão nos contratos de Vendas, que já foram ELIMINADOS ou CANCELADOS ","Previsões")
wnRel := SetPrint(cAlias, cNomeProg, cPerg , @cTitulo, cDesc1, cDesc2, cDesc3, .F., , .F., cTamanho)

pergunte( cPerg )

If (MV_PAR01 = 1)
		OGB001PRO()
	Else
		OGB001LIS()
EndIf
Return

Static Function OGB001PRO()

local cPrefixo   := PadR( "CTR", TamSX3( 'E1_PREFIXO' )[1] )
local cTipTit    := "PR"
Local cTexto     := ""
Local cDirInicial := GetSrvProfString('RootPath','')
Local lOpen   := .F.


cTexto += "PREVISÕES ELIMINADAS" + Chr(13) + chr(10) 
cTexto += Chr(13) + chr(10)

//verificar titulos de previsao no contas a receber que não tenham mais contrato ou contrato cancelado 
dbSelectArea( "SE1" )

// chave 1 SE1 : E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    
SE1->(dbSetOrder( 1 ))
If dbSeek( xFilial( "SE1" ) + cPrefixo)

	If dDataBase < cToD("21/08/2015") 
		While .Not. SE1->(Eof()) .And. SE1->E1_FILIAL  = xFilial( "SE1" ) .And. SE1->E1_PREFIXO = cPrefixo 
		    
		    DbselectArea( 'N8L' )
			N8L->( dbSetOrder( 1 ) ) 	// N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
			IF  N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
//				If AllTrim( SE1->E1_TIPO ) = AllTrim( cTipTit ) .And. !(Empty(SE1->E1_CTROG)) .And. SE1->E1_ORIGEM = "OGA290"	   
										
					dbSelectArea("NJR")
					NJR->( dbSetOrder( 1 ) )
					If dbSeek( xFilial( "NJR" ) + N8L->N8L_CODCTR ) 
						IF NJR_STATUS $ 'P|E|F'  // pendente, cancelado ou finalizado 	
							cTexto += SE1->E1_FILIAL+" "+SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA+" "+SE1->E1_TIPO + " " + N8L->N8L_CODCTR + Chr(13) + chr(10)
							RecLock( "SE1", .f. )
							SE1->(dbDelete())
							SE1->(MsUnLock())
							//nTit ++	 
						Endif	
					Else
						cTexto += SE1->E1_FILIAL + " " + SE1->E1_PREFIXO + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA + " " + SE1->E1_TIPO + " " + N8L->N8L_CODCTR + Chr(13) + chr(10)
						RecLock( "SE1", .f. )
						SE1->(dbDelete())
						SE1->(MsUnLock())
						//nTit ++	 
					Endif				 
				EndIf			
		SE1->(dbSkip())
		EndDo
	Else 
		MsgInfo("Programa com validade expirada, Favor entrar em contato com o suporte TOTVS")
		Msginfo("Processo Abortado!!!", "FINALIZADO")
	EndIf
EndIf
cPasta := cGetFile("REGDELPREV.TXT|REGDELPREV.TXT",OemToAnsi("Selecione a pasta para gravar"),nil,cDirinicial,lOpen,nor(GETF_LOCALHARD,GETF_RETDIRECTORY),.T.,.T.) 
Memowrite(cPasta , cTexto)
ALERT(cPasta)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OGB001LIS ³ Autor ³ Fernanda   ³ Data ³06/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OGB001LIS()

local cPrefixo := PadR( "CTR", TamSX3( 'E1_PREFIXO' )[1] )
local cTipTit  := "PR"
Local cTexto   := ""
Local cDirinicial := GetSrvProfString('RootPath','')
Local lOpen   := .f.


cTexto += "REGISTROS PREVISÕES" + Chr(13) + chr(10) 
cTexto += Chr(13) + chr(10)

//verificar titulos de previsao no contas a receber que não tenham mais contrato ou contrato cancelado 
dbSelectArea( 'SE1' )

// chave 1 SE1 : E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    
SE1->(dbSetOrder( 1 ))
If dbSeek( xFilial( 'SE1' ) + cPrefixo)
	While .Not. SE1->(Eof()) .And. SE1->E1_FILIAL  = xFilial( "SE1" ) .And. SE1->E1_PREFIXO = cPrefixo
	    cCodCtr := Posicione('N8L',1 ,FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO ), "N8L_CODCTR")
	    
		If AllTrim( SE1->E1_TIPO ) = AllTrim( cTipTit ) .And. !(Empty(SE1->E1_CTROG)) .And. SE1->E1_ORIGEM = "OGA290"	   
			dbSelectArea("NJR")
			dbSetOrder( 1 ) 
			If dbSeek( xFilial( "NJR" ) + SE1->E1_CTROG ) 
				IF NJR->NJR_STATUS $ 'P|E|F'  // pendente, cancelado ou finalizado 	
					cTexto += SE1->E1_FILIAL+" "+SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA+" "+SE1->E1_TIPO+" " + cCodCtr + Chr(13) + chr(10)
				Endif	
			Else
				cTexto += SE1->E1_FILIAL+" "+SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA+" "+SE1->E1_TIPO+" " + cCodCtr + Chr(13) + chr(10)	 
			Endif 
		EndIf
		SE1->(dbSkip())
	EndDo
EndIf
//Memowrite("C:\REGLISPREV.TXT" , cTexto)

 //cArquivo := cGetFile("Arquivos TXT(*.TXT)|*.TXT",OemToAnsi("Selecione o arquivo de Itens de Cupons para Importação: "),nil,cDirInicial,lOpen,GETF_RETDIRECTORY,.t.,.t.)
cPasta := cGetFile("REGLISPREV.TXT|REGLISPREV.TXT",OemToAnsi("Selecione a pasta para gravar"),nil,cDirinicial,lOpen,nor(GETF_LOCALHARD,GETF_RETDIRECTORY),.T.,.T.) 
Memowrite(cPasta , cTexto)
//MsgInfo("Processo Concluído!!!" + chr(13) +  chr(13) + "Disponivel em \PROTHEUS_DATA\" + chr(13) + cTexto, "FINALIZADO" )
ALERT(cPasta)

 
Return
