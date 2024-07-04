#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1156.CH"

Static nSaveSx8		:= 0				// Variavel para Controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156                          ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Abre o assist๊nte de gera็ใo de carga.                                 บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ Nenhum.                                                                บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA1156()
	Local oLJInitialLoadMakerWizard		:= Nil
	Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()
	Local oLJCMessageManager				:= GetLJCMessageManager()//Controle Msgs
	Local aTableGroups					:= {}
	Local lDefaultDataCreated			:= .F.
	
	LjGrvLog( "Carga","ID_INICIO")

	//Trata msg ja no inico por causa da instancia do obj LJCFileServerConfiguration
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show(	STR0015 +	CHR(13)+CHR(10)	+; // "Configura็๕es do servidor de carga nใo encontradas."
									STR0016 +	CHR(13)+CHR(10)	+; // "Caso esteja em um server diferente ou com balanceamento de cargas,"
									STR0017 +	CHR(13)+CHR(10)	+; // "Informe no servidor atual ou Slaves a configura็ใo do servidor de cargas. Exemplo:"
									"[LJFileServer]" 			+	CHR(13)+CHR(10)	+;
									"Location=127.0.0.1"  	+	CHR(13)+CHR(10)	+;
									"Path=\ljfileserver\" 	+	CHR(13)+CHR(10)	+;
									"Port=8084"  				+	CHR(13)+CHR(10)	)
		oLJCMessageManager:Clear()
	EndIf

	DbSelectArea( "MBU" )
 	If Empty(MBU->(IndexKey(2)))
		Aviso(STR0008, STR0013 + CHR(13)+CHR(10) +; //#STR0008->"Aten็ใo" ##STR0013->"O ambiente nใo estแ preparado para a utiliza็ใo desta rotina."
						 STR0014, {"OK"})  //#STR0014->"Favor aplicar o update 'U_UPDLO105' ou entre em contato com o suporte."

	ElseIf FindFunction("__FWSeriNotCompactReady")
		aTableGroups := LOJA1156RDB()	
		
		If Len( aTableGroups ) == 0
			aTableGroups := LOJA1156CDB()
			lDefaultDataCreated	:= .T.
		EndIf
		
		oLJInitialLoadMakerWizard := LJCInitialLoadMakerWizard():New( aTableGroups )
		oLJInitialLoadMakerWizard:cPathOfRepository := oLJILFileServerConfiguration:GetPath()
		oLJInitialLoadMakerWizard:lHasChange := lDefaultDataCreated
		oLJInitialLoadMakerWizard:Show()	
		
	Else
		Aviso( STR0008, STR0001, {"OK"} ) // "Aten็ใo!" "ษ necessแrio atualizar o fonte FWSERIALIZE.PRW"
	EndIf
	
	LjGrvLog( "Carga","ID_FIM")
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156CDB                       ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Administra Grupo de Tabelas Padroes.                                   บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ Nenhum.                                                                บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA1156CDB()
	Local oTransferTables	:= Nil
	Local aTableGroups		:= {}
	Local oTable1			:= Nil
	Local oTable2			:= Nil	
	Local oTable3			:= Nil	
	Local oTable4			:= Nil	
	Local oTable5			:= Nil	
	Local oTable6			:= Nil	
	Local oTable7			:= Nil	
	Local oTable8			:= Nil	
	Local oTable9			:= Nil	
	Local oTable10			:= Nil	
	Local oTable11			:= Nil	
	Local oTable12			:= Nil
	Local oTable13			:= Nil
	Local oPTable1			:= Nil
	Local oSTable1			:= Nil
	
	If MsgYesNo( STR0009 )
		oTransferTables := LJCInitialLoadTransferTables():New()

		oTable13 := LJCInitialLoadCompleteTable():New( "AI0", { xFilial( "AI0" ) } )			
		oTable1 := LJCInitialLoadCompleteTable():New( "SA1", { xFilial( "SA1" ) } )
		oTable2 := LJCInitialLoadCompleteTable():New( "SB0", { xFilial( "SB0" ) } )		
		oTable3 := LJCInitialLoadCompleteTable():New( "SB1", { xFilial( "SB1" ) } )		
		oTable4 := LJCInitialLoadCompleteTable():New( "SLK", { xFilial( "SLK" ) } )		
		oTable5 := LJCInitialLoadCompleteTable():New( "SAE", { xFilial( "SAE" ) } )		
		oTable6 := LJCInitialLoadCompleteTable():New( "SE4", { xFilial( "SE4" ) } )		
		oTable7 := LJCInitialLoadCompleteTable():New( "SF4", { xFilial( "SF4" ) } )		
		oTable8 := LJCInitialLoadCompleteTable():New( "SA6", { xFilial( "SA6" ) } )		
		oTable9 := LJCInitialLoadCompleteTable():New( "SLF", { xFilial( "SLF" ) } )		
		oTable10 := LJCInitialLoadCompleteTable():New( "SA6", { xFilial( "SA6" ) } )
		oTable11 := LJCInitialLoadCompleteTable():New( "SLF", { xFilial( "SLF" ) } )		
		oTable12 := LJCInitialLoadCompleteTable():New( "SA3", { xFilial( "SA3" ) } )
	
				
		oPTable1 := LJCInitialLoadPartialTable():New( "SX5" )
		oPTable1:AddRecord( 1, "23" )	
		
		oSTable1 := LJCInitialLoadSpecialTable():New( "SBI", { { xFilial( "SBI" ) }, "" } )

		oTransferTables:AddTable( oTable13 )		
		oTransferTables:AddTable( oTable1 )
		oTransferTables:AddTable( oTable2 )		
		oTransferTables:AddTable( oTable3 )
		oTransferTables:AddTable( oTable4 )		
		oTransferTables:AddTable( oTable5 )		
		oTransferTables:AddTable( oTable6 )		
		oTransferTables:AddTable( oTable7 )		
		oTransferTables:AddTable( oTable8 )		
		oTransferTables:AddTable( oTable9 )		
		oTransferTables:AddTable( oTable10 )		
		oTransferTables:AddTable( oTable11 )
		oTransferTables:AddTable( oTable12 )
						
		oTransferTables:AddTable( oPTable1 )

		oTransferTables:AddTable( oSTable1 )		

		aTableGroups := { { "1", STR0010, STR0011, oTransferTables, "1" } }		
	EndIf
Return aTableGroups

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156RDB                       ณ Autor: Vendas CRM ณ Data: 16/10/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Le do banco de dados as informa็๕es dos grupos de tabelas disponํveis. บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ Nenhum.                                                                บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ aTableGroups: Array com os grupos de tabelas disponํveis.              บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA1156RDB()

Local aTableGroups	:= {}
Local oTransfTbl	:= LJCInitialLoadTransferTables():New()
Local lNewLoad		:= ExistFunc("Lj1149NwLd")

DbSelectArea( "MBU" )
DbSetOrder(2)
DbGoTop()	

While MBU->( !EOF() ) .AND. MBU->MBU_TIPO <> '2'  //soh mostra templates (nao mostra o que for carga gerada)
	aAdd( aTableGroups, Array( 5 ) )
	aTableGroups[Len(aTableGroups)][1] := MBU->MBU_CODIGO
	aTableGroups[Len(aTableGroups)][2] := MBU->MBU_NOME
	aTableGroups[Len(aTableGroups)][3] := MBU->MBU_DESCRI
	If lNewLoad
		aTableGroups[Len(aTableGroups)][4] := oTransfTbl
	Else
		aTableGroups[Len(aTableGroups)][4] := LOJA1156RTG( MBU->MBU_CODIGO )
	EndIf	
	aTableGroups[Len(aTableGroups)][5] := MBU->MBU_INTINC
	
	MBU->( DbSkip() )
End

Return aTableGroups

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156RTG                       ณ Autor: Vendas CRM ณ Data: 16/10/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Le um grupo de tabela e retorna seu LJCInitialLoadTransferTables.      บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ Nenhum.                                                                บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ oTransferTables: Objeto do tipo LJCInitialLoadTransferTables.          บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA1156RTG( cTableGroup )
	Local oTransferTables	:= LJCInitialLoadTransferTables():New()
	Local oTempTable		:= Nil
	Local aBranches			:= {}
	Local aRecords			:= {}
	Local aParams			:= {}	
	
	DbSelectArea( "MBV" )
	DbSetOrder( 1 )
	If MBV->( DbSeek( xFilial( "MBV" ) + cTableGroup ) )
		While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + cTableGroup .And.;
				MBV->( !EOF() )
			oTempTable := Nil
			//tipo -> completa
			If AllTrim( MBV->MBV_TIPO ) == "1"
				oTempTable := LJCInitialLoadCompleteTable():New( MBV->MBV_TABELA )
				aBranches := {}
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				If MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBX->( !EOF() )
						aAdd( aBranches, MBX->MBX_FIL )
						MBX->( DbSkip() )
					End
				EndIf
				oTempTable:aBranches := aBranches
				
				oTempTable:cFilter := MBV->MBV_FILTRO 
			
				oTempTable:cQtyRecords := MBV->MBV_QTDREG
			//tipo -> parcial	
			ElseIf AllTrim( MBV->MBV_TIPO ) == "2"
				oTempTable := LJCInitialLoadPartialTable():New( MBV->MBV_TABELA )
				aRecords := {}
				DbSelectArea( "MBW" )
				DbSetOrder( 1 )
				If MBW->( DbSeek( xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBW->MBW_FILIAL + MBW->MBW_CODGRP + MBW->MBW_TABELA == xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBW->( !EOF() )
						aAdd( aRecords, { MBW->MBW_INDICE, MBW->MBW_SEEK  } )
						MBW->( DbSkip() )
					End
				EndIf
				oTempTable:aRecords := aRecords
				
				oTempTable:cFilter := MBV->MBV_FILTRO
				
				oTempTable:cQtyRecords := MBV->MBV_QTDREG
			//tipo -> especial
			ElseIf AllTrim( MBV->MBV_TIPO ) == "3"
				oTempTable := LJCInitialLoadSpecialTable():New( MBV->MBV_TABELA )
				If MBV->MBV_TABELA == "SBI"
					aParams := Array( 2 )
					aBranches := {}
					DbSelectArea( "MBX" )
					DbSetOrder( 1 )
					If MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
						While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
								MBX->( !EOF() )
							aAdd( aBranches, MBX->MBX_FIL )
							MBX->( DbSkip() )
						End
					EndIf
					aParams[1] := aBranches
					
					aParams[2] := MBV->MBV_FILTRO
					
					oTempTable:aParams := aParams
					oTempTable:cQtyRecords := MBV->MBV_QTDREG
				EndIf
			EndIf
			aAdd( oTransferTables:aoTables, oTempTable )
			MBV->( DbSkip() )
		End
	EndIf
Return oTransferTables

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156WDB                       ณ Autor: Vendas CRM ณ Data: 16/10/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Grava os grupos de tabelas disponํveis no banco de dados.              บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ aTableGroups: Array com os grupos de tabelas disponํveis.              บฑฑ
ฑฑบ             ณ lLoad: determina se eh uma carga (.T.) ou um template (.F.)            บฑฑ
ฑฑบ             ณ cCodInitialLoad:Codigo da carga (quando lLoad = .T.), por referencia   บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nenhum.                                                                บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA1156WDB( aTableGroups, lLoad, cCodInitialLoad )
	Local nCount 		:= 0
	Local nCount2		:= 0
	Local nCount3		:= 0
	Local aProcGroups	:= {}
	Local aProcTables	:= {}
	Local cOrderLoad 	:= MBUOrderIncremental() //verifica antes a ordem da proxima carga, porque se precisar criar o xml vai ter q percorrer as tabelas MB's antes de incluir outro registro
	Local cCodMBU		:= ""
	
	Default lLoad := .F. //determina se eh uma carga (.T.) ou um template (.F.)
	
	LjGrvLog( "Carga","Gera็ใo carga Inicio ")
	
	For nCount := 1 To Len( aTableGroups )			
		// Procura informa็๕es do grupo de tabela, se nใo encontrar, cria ela.
		DbSelectArea( "MBU" )
		DbSetOrder(1)
		DbGoTop()			
		If (lLoad) .OR. Empty(aTableGroups[nCount][1]) .OR. MBU->( !DbSeek( xFilial( "MBU" ) + aTableGroups[nCount][1] ) )
			LJSetSvSx8(GetSx8Len()) // Controle de semaforo

			cCodMBU := GetSXENum( "MBU", "MBU_CODIGO" )
			LjGrvLog( "Carga","MBU_CODIGO ",cCodMBU )
			If MBU->(!DbSeek(xFilial("MBU")+cCodMBU))
				RecLock( "MBU", .T. )
				Replace MBU->MBU_FILIAL	With xFilial( "MBU" )
				Replace MBU->MBU_CODIGO	With cCodMBU
				MBU->(MsUnLock())
			EndIf						
			aAdd( aProcGroups, MBU->MBU_CODIGO )
			
			//Popula tabela MH1 para execucao da carga automatica via JOB ou Scheduller
			If AliasInDic("MH1") .AND. Alltrim(aTableGroups[nCount][5]) == "2"	 //Se for somente carga incremental e gera automแtica e for template
				DbSelectArea("MH1")
				MH1->(dbSetOrder(1))		
				If !MH1->(dbSeek(xFilial("MH1")+(IIF(lLoad , aTableGroups[nCount][1], cCodMBU ))))  
					LjGrvLog( "Carga","Cria registro para gera็ใo automแtica ")
					RecLock( "MH1", .T. )
					MH1->MH1_FILIAL	:= xFilial("MH1")
					MH1->MH1_COD		:= (IIF(lLoad , aTableGroups[nCount][1], cCodMBU ))
					MH1->MH1_TIME		:= 1
					MH1->MH1_STATUS	:= "A"
					MH1->MH1_HORAI	:= "00:00"
					MH1->MH1_HORAF	:= "23:59"
					MH1->(MsUnLock())
				EndIf		
			EndIf
			
			If !lLoad //se for um registro de template joga o codigo do registro na columa 1 do array dos grupos
				ConfirmSx8() //Confirma a numeracao gerada para esta carga
				aTableGroups[nCount][1] := MBU->MBU_CODIGO
			Else //se for um registro de carga, devolve pelo parametro por referencia, o codigo da carga
				cCodInitialLoad :=  MBU->MBU_CODIGO
			EndIf
			
		Else
			aAdd( aProcGroups, aTableGroups[nCount][1] )
		EndIf
	
		If RecLock( "MBU", .F. )
			Replace MBU->MBU_NOME 		With aTableGroups[nCount][2]
			Replace MBU->MBU_DESCRI 		With aTableGroups[nCount][3]
			Replace MBU->MBU_TIPO 		With (IIF(lLoad , "2", "1"))
			Replace MBU->MBU_INTINC		With IIF( Empty(aTableGroups[nCount][5]) , "1" , aTableGroups[nCount][5]) //se tiver em branco (cargas antigas, legado) considera como carga inteira. Dessa forma as cargas antes desta versao serao convertidas para o tipo "carga inteira"
			
			If lLoad //grava dados exclusivos do tipo = carga (MBU_TIPO = 2)
				LjGrvLog( "Carga","Grava resgistros exclusivos ")
				Replace MBU->MBU_DATA	With dDataBase
				Replace MBU->MBU_HORA	With Time()
				Replace MBU->MBU_CODTPL	With aTableGroups[nCount][1] //codigo do template usado na carga (auto-associacao na MBU)
				//carga incremental controla a ordem
				If aTableGroups[nCount][5] == '2'
					Replace MBU->MBU_ORDEM	With cOrderLoad
				EndIf
			EndIf
			
			MBU->(MsUnLock())
		Else
			LjGrvLog( "Carga","Nใo conseguiu efetuar RecLock na tabela MBU ")
		EndIf	
		
		aProcTables := {}	
		For nCount2 := 1 To Len( aTableGroups[nCount][4]:aoTables )		
			// Adiciona a tabela na lista de tabelas processadas
			aAdd( aProcTables, aTableGroups[nCount][4]:aoTables[nCount2]:cTable )
		
			// Procura informa็๕es da tabela, se nใo encontrar, cria ela.
			DbSelectArea( "MBV" )
			DbSetOrder( 1 )
			If MBV->( !DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO + aTableGroups[nCount][4]:aoTables[nCount2]:cTable ) )
				RecLock( "MBV", .T. )
				Replace MBV->MBV_FILIAL	With xFilial( "MBV" )
				Replace MBV->MBV_CODGRP	With MBU->MBU_CODIGO
				Replace MBV->MBV_TABELA	With aTableGroups[nCount][4]:aoTables[nCount2]:cTable 
				MBV->(MsUnLock())
			EndIf
	
			If Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadCompleteTable")
				// Grava
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "1"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:cFilter
				MBV->(MsUnLock())
	
				// Apaga as filiais no MBX
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )
				While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
						MBX->( !EOF() )
					RecLock( "MBX", .F. )
					MBX->( DbDelete() )
					MBX->( MsUnLock() )
					MBX->( DbSkip() )
				End

				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aBranches )
					RecLock( "MBX", .T. )
					Replace MBX->MBX_FILIAL	With xFilial( "MBX" )
					Replace MBX->MBX_CODGRP	With MBV->MBV_CODGRP
					Replace MBX->MBX_TABELA	With MBV->MBV_TABELA
					Replace MBX->MBX_FIL	With aTableGroups[nCount][4]:aoTables[nCount2]:aBranches[nCount3]
					MBX->( MsUnLock() )
				Next
			ElseIf Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadPartialTable")
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "2"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:cFilter
				MBV->(MsUnLock())

				// Apaga os registros no MBW
				DbSelectArea( "MBW" )
				DbSetOrder( 1 )
				If MBW->( DbSeek( xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBW->MBW_FILIAL + MBW->MBW_CODGRP + MBW->MBW_TABELA == xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBW->( !EOF() )
						RecLock( "MBW", .F. )
						MBW->( DbDelete() )
						MBW->( MsUnLock() )						
						MBW->( DbSkip() )
					End
				EndIf	   
		
				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aRecords )
					RecLock( "MBW", .T. )
					Replace MBW->MBW_FILIAL	With xFilial( "MBW" )
					Replace MBW->MBW_CODGRP	With MBV->MBV_CODGRP
					Replace MBW->MBW_TABELA	With MBV->MBV_TABELA
					Replace MBW->MBW_INDICE	With aTableGroups[nCount][4]:aoTables[nCount2]:aRecords[nCount3][1]
					Replace MBW->MBW_SEEK	With aTableGroups[nCount][4]:aoTables[nCount2]:aRecords[nCount3][2]
					MBW->( MsUnLock() )
				Next				
			ElseIf Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadSpecialTable")				
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "3"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:aParams[2]
				MBV->(MsUnLock())
				
				// Apaga as filiais no MBX
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )
				While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
						MBX->( !EOF() )
					RecLock( "MBX", .F. )
					MBX->( DbDelete() )
					MBX->( MsUnLock() )
					MBX->( DbSkip() )
				End
		
				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aParams[1] )
					RecLock( "MBX", .T. )
					Replace MBX->MBX_FILIAL	With xFilial( "MBX" )
					Replace MBX->MBX_CODGRP	With MBV->MBV_CODGRP
					Replace MBX->MBX_TABELA	With MBV->MBV_TABELA
					Replace MBX->MBX_FIL	With aTableGroups[nCount][4]:aoTables[nCount2]:aParams[1][nCount3]
					MBX->( MsUnLock() )
				Next				
			EndIf
		Next

		// Apaga as tabelas desse grupo
		DbSelectArea( "MBV" )
		DbSetOrder( 1 )
		If MBV->( DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO ) )
			While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + MBU->MBU_CODIGO .And.;
					MBV->( !EOF() )
				If Len(aProcTables) > 0 .And. aScan( aProcTables, { |x| x == MBV->MBV_TABELA } ) == 0
					RecLock( "MBV", .F. )
					MBV->( DbDelete() )
					MBV->( MsUnLock() )
				EndIf
				MBV->( DbSkip() )				
			End
		EndIf
	Next
	
	//Se for do tipo template, apaga os grupos (que tenham sido removidos pelo usuario) e suas tabelas 
	If !lLoad 
		LjGrvLog( "Carga","Apaga Grupos removidos pelo usuario ")
		DbSelectArea( "MBU" )
		DbSetOrder(2)
		DbGoTop()	
		While MBU->( !EOF() ) .AND. MBU->MBU_TIPO <> "2" //somente templates (tipo 1 = template, 2 = carga - se for registro antigo, o campo tipo pode estar em branco)
	   		If aScan( aProcGroups, { |x| x == MBU->MBU_CODIGO } ) == 0
				RecLock( "MBU", .F. )
				MBU->( DbDelete() )
				MBU->( MsUnLock() )
				
				// Apaga as tabelas desse grupo
				DbSelectArea( "MBV" )//MBV_FILIAL+MBV_CODGRP+MBV_TABELA
				DbSetOrder( 1 )
				If MBV->( DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO ) )
					While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + MBU->MBU_CODIGO .And.;
							MBV->( !EOF() )
						RecLock( "MBV", .F. )
						MBV->( DbDelete() )
						MBV->( MsUnLock() )
						MBV->( DbSkip() )				
					End
				EndIf

				DbSelectArea( "MBX" )//MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL
				DbSetOrder( 1 )
				If MBX->( DbSeek( xFilial( "MBX" ) + MBU->MBU_CODIGO ) )
					While	MBX->MBX_FILIAL + MBX->MBX_CODGRP ==  xFilial( "MBX" ) + MBU->MBU_CODIGO .And.;
							MBX->( !EOF() )
						RecLock( "MBX", .F. )
						MBX->( DbDelete() )
						MBX->( MsUnLock() )
						MBX->( DbSkip() )				
					End
				EndIf

			EndIf
			MBU->( DbSkip() )
		End		                   
	EndIf
	
	LjGrvLog( "Carga","Gera็ใo carga Inicio ")
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156Job                       ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Executa a gera็ใo de carga atrav้s de JOB.                             บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ cTableGroup: codigo da grupo de tabelas.                               บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       	
Function LOJA1156Job( cTableGroup )
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJLoadUI					:= LJCInitialLoadMakerConsoleUI():New()
	Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()	
	Local oLJInitialLoad				:= Nil
	Local lRet						:= .F.
	Local cCodInitialLoad				:= ""  //codigo da carga inicial (carga em si, nao o template)
	Local cEntireInc					:= ""
	Local cName						:= ""
	Local cDesc						:= ""
	Local oTransferTables				:= Nil
	
	LjGrvLog( "Carga","ID_INICIO")	
	
	//Trata msg ja no inico por causa da instancia do obj LJCFileServerConfiguration
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show(	STR0015 +	CHR(13)+CHR(10)	+; // "Configura็๕es do servidor de carga nใo encontradas."
									STR0016 +	CHR(13)+CHR(10)	+; // "Caso esteja em um server diferente ou com balanceamento de cargas,"
									STR0017 +	CHR(13)+CHR(10)	+; // "Informe no servidor atual ou Slaves a configura็ใo do servidor de cargas. Exemplo:"
									"[LJFileServer]" 			+	CHR(13)+CHR(10)	+;
									"Location=127.0.0.1"  	+	CHR(13)+CHR(10)	+;
									"Path=\ljfileserver\" 	+	CHR(13)+CHR(10)	+;
									"Port=8084"  				+	CHR(13)+CHR(10)	)
		oLJCMessageManager:Clear()
	EndIf
	
	If ValType(cTableGroup) <> "C" .OR. Empty( cTableGroup ) 
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LOJA1156Job", 1, STR0012 ) ) // "Nใo foi informado um codigo de grupo de tabelas."
	Else
		oTransferTables := LOJA1156RTG( cTableGroup )	
	EndIf
	
	If !oLJCMessageManager:HasError()
		
		cEntireInc	:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_INTINC")
		cName		:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_NOME")
		cDesc		:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_DESCRI")
	  	aTableGroups := { { cTableGroup, cName, cDesc, oTransferTables, cEntireInc } }	
	       
	 	//Grava a carga que sera gerada e pega o codigo dela por referencia
		LOJA1156WDB( aTableGroups, .T., @cCodInitialLoad )
		
		oLJInitialLoad := LJCInitialLoadMaker():New( oLJILFileServerConfiguration:GetPath() + cCodInitialLoad )//concatena no path o codigo da carga 	
		oLJInitialLoad:SetTransferTables( oTransferTables )
		oLJInitialLoadMaker:SetExportType(cEntireInc)		
		oLJInitialLoadMaker:SetCodInitialLoad( cCodInitialLoad )
		oLJLoadUI := LJCInitialLoadMakerConsoleUI():New()
		oLJInitialLoad:AddObserver( oLJLoadUI )
		oLJInitialLoad:Execute()			
		If !oLJCMessageManager:HasError()
			
			LJ1156XMLResult()
			
			lRet := .T.
		EndIf			
	EndIf
		
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0003 ) // "Houve alguma mensagem durante a gera็ใo da carga."
		oLJCMessageManager:Clear()
	EndIf
	
	LjGrvLog( "Carga","ID_FIM")
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LOJA1156PJob                      ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Gera็ใo de carga por solicita็ใo do pain้l de precifica็ใo.            บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ cTableGroup: C๓digo do grupo de tabelas a ser utilizado.               บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       	
Function LOJA1156PJob( cTableGroup )
	Local oObject  := nil
	Local lPainel  := .F.

	lPainel := SuperGetMV("MV_LJGEPRE",.F.,.F.)
	
	If lPainel
		oObject := PainelPrecificacao():New()
		
		If oObject:Lj3GerarCarga()
			oObject:Lj3ExecCarga(LOJA1156Job( cTableGroup ))
		EndIf
	EndIf
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ MBUOrderIncremental               ณ Autor: Vendas CRM ณ Data: 07/08/12 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Busca a ordem da proxima carga incremental                            บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ cOrder: proximo numero da ordem                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       	
Function MBUOrderIncremental()
Local cOrder		:= ""

cOrder := LJILLastOrderLoad()
If Empty(cOrder) //se nao tiver a ordem gravada, forca a gravacao baseada na ultim carga do xml (gera novamente o xml pra garantir que esta atualizado)
	LJ1156XMLResult(.T.)
	cOrder := LJILLastOrderLoad()
EndIf

cOrder := cValToChar(Val(cOrder) + 1) //soma +1
cOrder := PADL(cOrder,10,'0') //preenche com 0 a esquerda

LjGrvLog( "Carga","Ordem da proxima carga incremental " + cOrder )

Return cOrder



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LJ1156CountLoads               ณ Autor: Vendas CRM ณ Data: 07/08/12 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ retorna o total de cargas incrementais                          บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno:     nTotalLoads: total de cargas incrementais                                   บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       	
Function LJ1156CountLoads()
Local cQuery		:= ""
Local nTotalLoads		:= 0


//verifica o total de cargas (considera somente registros do tipo carga (2). Nao considera os templates(1)
cQuery := " SELECT COUNT(*) AS TOTLOAD FROM " + RetSqlName('MBU') + " WHERE MBU_TIPO = '2' AND D_E_L_E_T_ = ' ' " 
cQuery := ChangeQuery(cQuery)					
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TMP', .F., .T.)
nTotalLoads := TMP->TOTLOAD
TMP->(dbCloseArea()) 

LjGrvLog( "Carga","Total de cargas incrementais ", nTotalLoads )

Return nTotalLoads


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Fun็ใo: ณ LJ1156XMLResult                   ณ Autor: Vendas CRM ณ Data: 06/07/12 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ cria o xml com o resultado serializado (lista das cargas)              บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Parametro: ณ lUpdateOrderLoad: forca a criacao do xml da ultima carga               บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                 

Function LJ1156XMLResult(lUpdateOrderLoad)

Local oLJILConfiguration	:= LJCInitialLoadConfiguration():New()	
Local oResult				:= Nil		//objeto tipo LJCInitialLoadMakerResult -> array de LJCInitialLoadGroupConfig 
Local oTransferTable		:= Nil		
Local oTransferFiles		:= Nil
Local oFile				:= Nil
Local oGroup				:= Nil		//objeto tipo LJCInitialLoadGroupConfig com dados de uma carga especifica
Local nCountTable			:= 0
Local nCountBranche		:= 0
Local nI					:= 0
Local cLastOrder			:= ""

Default lUpdateOrderLoad := .F. //quando for true, forca a criacao do xml da ultima carga mesmo que a ordem seja inferior a ultima (isso ocorre quando restaura o msexp)

LjGrvLog( "Carga","Grava XML com resultado da gera็ใo da carga ")

oResult := LJCInitialLoadMakerResult():New()

DbSelectArea("MBU")
DbSetOrder(2) // MBU_FILIAL + MBU_TIPO              
If DbSeek(xFilial("MBU") + '2')
	While MBU->(!EOF()) .AND. MBU->MBU_FILIAL + MBU_TIPO == xFilial("MBU") + '2'
		
		oTransferTable := LOJA1156RTG( MBU->MBU_CODIGO ) //array de tabelas transferiveis para a carga (MBU_CODIGO)
		oTransferFiles := LJCInitialLoadMakerTransferFiles():New()
	
		//Para cada tabela transferivel verifica quais filiais vai transferir e define os arquivos da transferencia
		//as exportacoes completa e especial sao quebradas por filial. A exportacao parcial nao gera MBX (filial) 
		For nCountTable := 1 to Len( oTransferTable:aoTables ) 
			
			DO CASE
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadCompleteTable")
					//oTransferTable:aoTables[nCountTable] -> oCompleteTable
					For nCountBranche := 1 to Len ( oTransferTable:aoTables[nCountTable]:aBranches )
						oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, oTransferTable:aoTables[nCountTable]:aBranches[nCountBranche] )
						oFile:nRecords := Posicione("MBX", 1, XFilial("MBX") + MBU->MBU_CODIGO + oTransferTable:aoTables[nCountTable]:cTable + oTransferTable:aoTables[nCountTable]:aBranches[nCountBranche] , "MBX_QTDREG")
						oTransferFiles:AddFile(oFile)
					Next
		
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadPartialTable")
					//oTransferTable:aoTables[nCountTable] -> oPartialTable
					oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, "" )
					oFile:nRecords := oTransferTable:aoTables[nCountTable]:cQtyRecords
					oTransferFiles:AddFile(oFile)
		
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadSpecialTable")
					//oTransferTable:aoTables[nCountTable] -> oSpecialTable
					For nCountBranche := 1 To Len( oTransferTable:aoTables[nCountTable]:aParams[1] )
						oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, oTransferTable:aoTables[nCountTable]:aParams[1][nCountBranche] )
						oFile:nRecords := Posicione("MBX", 1, XFilial("MBX") + MBU->MBU_CODIGO + oTransferTable:aoTables[nCountTable]:cTable + oTransferTable:aoTables[nCountTable]:aParams[1][nCountBranche] , "MBX_QTDREG")
						oTransferFiles:AddFile(oFile)
					Next
					
			ENDCASE
			
		Next
		

		oGroup := LJCInitialLoadGroupConfig():New(oTransferFiles, oTransferTable, TMKDateTime():This(MBU->MBU_DATA,MBU->MBU_HORA), LJILRealDriver(), IIf( ExistFunc("LJILRealExt") , LJILRealExt() , GetDBExtension() )	, MBU->MBU_ORDEM , MBU->MBU_INTINC, MBU->MBU_CODIGO , MBU->MBU_NOME , MBU->MBU_DESCRI, MBU->MBU_CODTPL )
	
		oResult:AddGroup(oGroup)
	
		MBU->( DbSkip() )
	End

	cLastOrder := LJILLastOrderLoad()
	For nI := Len(oResult:aoGroups) to 1 Step -1
		//soh atualiza se a chamada vier da delecao com restauracao da msexp (pra voltar a ordem), ou se for com uma ordem maior que a ultima)
		If oResult:aoGroups[nI]:cEntireIncremental == "2" .AND. ( lUpdateOrderLoad .OR. oResult:aoGroups[nI]:cOrder > cLastOrder )  
			WLastIncOrder(oResult:aoGroups[nI]:cOrder ) //grava a ordem da ultima carga incremental disponivel
			Exit
		EndIf
	Next nI	
	
EndIf

LJPersistObject( oResult:ToXML(.F.), cEmpAnt + "LJCInitialLoadMakerResult", oLJILConfiguration:GetILPersistPath() )

Return oResult


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Classe: ณ LJCInitialLoadMakerConsoleUI      ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Classe para a exibi็ใo do progresso da gera็ใo da carga para console.  บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCInitialLoadMakerConsoleUI
	Method New()
	Method Update()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     M้todo: ณ New                               ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Construtor.                                                            บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ Nenhum.                                                                บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCInitialLoadMakerConsoleUI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     M้todo: ณ Update                            ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Exibe no console o progresso da gera็ใo de carga.                      บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ oLJInitialLoadMakerProgress: Objeto LJCInitialLoadMakerProgress        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ Nil                                                                    บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Update( oLJInitialLoadMakerProgress ) Class LJCInitialLoadMakerConsoleUI
	Local cOut := ""
	Do Case
		Case oLJInitialLoadMakerProgress:nStatus == 1
			cOut += STR0004 + " - " // "Iniciado"
		Case oLJInitialLoadMakerProgress:nStatus == 2
			cOut += STR0005 + " - " // "Exportando"
		Case oLJInitialLoadMakerProgress:nStatus == 3
			cOut += STR0006 + " - " // "Compactando"
		Case oLJInitialLoadMakerProgress:nStatus == 4
			cOut += STR0007 + " - " // "Finalizado"
	EndCase
	
	If ValType(oLJInitialLoadMakerProgress:aTables) != "U"
		If Len(oLJInitialLoadMakerProgress:aTables) > 0 .And. (oLJInitialLoadMakerProgress:nActualTable >= 0 .And. oLJInitialLoadMakerProgress:nActualTable <= Len(oLJInitialLoadMakerProgress:aTables) )
			cOut += oLJInitialLoadMakerProgress:aTables[oLJInitialLoadMakerProgress:nActualTable] + " (" + AllTrim(Str(oLJInitialLoadMakerProgress:nActualTable)) + "/" + AllTrim(Str(Len(oLJInitialLoadMakerProgress:aTables))) + ")" + " - "
		EndIf
	EndIf
	
	If ValType( oLJInitialLoadMakerProgress:nActualRecord ) != "U" .And. ValType(oLJInitialLoadMakerProgress:nTotalRecords) != "U"
		If oLJInitialLoadMakerProgress:nActualRecord > 0 .And. oLJInitialLoadMakerProgress:nTotalRecords > 0
			cOut += AllTrim(Str(oLJInitialLoadMakerProgress:nActualRecord)) + "/" + AllTrim(Str(oLJInitialLoadMakerProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((oLJInitialLoadMakerProgress:nActualRecord*100)/oLJInitialLoadMakerProgress:nTotalRecords,2))) + "%)" + " - "
		EndIf
	EndIf
	
	If ValType( oLJInitialLoadMakerProgress:nRecordsPerSecond ) != "U"
		cOut += AllTrim(Str(oLJInitialLoadMakerProgress:nRecordsPerSecond)) + "r/s"
	EndIf
	
	ConOut( cOut )
Return

//------------------------------------------------------------------------------   
/*/{Protheus.doc} LJGetSvSx8
Obtem a quantidade de n๚meros reservados que estใo na pilha, referente ao controle de semaforo.
Funcao utilizada para controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

@author  Varejo
@version P11.8
@since   16/04/2015
@return	 Quantidade de n๚meros reservados que estใo na pilha ainda nao confirmados pela funcao ConfirmSx8()
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function LJGetSvSx8()
Return nSaveSx8

//------------------------------------------------------------------------------   
/*/{Protheus.doc} LJSetSvSx8
Seta a quantidade de n๚meros reservados que estใo na pilha referente ao controle de semaforo.
Funcao utilizada para controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

@param	 nNumSx8 - Quantidade de n๚meros reservados que estใo na pilha referente ao controle de semaforo (Padrao: GetSx8Len())
@author  Varejo
@version P11.8
@since   16/04/2015
@return	 Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function LJSetSvSx8(nNumSx8)
Default nNumSx8 := GetSx8Len()

nSaveSx8 := nNumSx8

Return Nil
