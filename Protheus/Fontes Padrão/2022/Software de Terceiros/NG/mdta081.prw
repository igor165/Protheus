#Include "MDTA081.ch"
#Include "Protheus.ch"

#Define _OPC_cGETFILE (GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_SHAREAWARE )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA081
Programa de Cadastro de Grupo de 
CID (Classificacao Internacional de Doencas) 

@author Denis Hyroshi de Souza
@since 07/02/07
@return True 
/*/
//---------------------------------------------------------------------
Function MDTA081()

	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina := MenuDef()
	Private cCadastro := OemtoAnsi(STR0001) //"Grupo de Doen�as (CID)"
	Private aCHKDEL := {}
	Private aChkSql := {}
	Private bNGGRAVA

	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TKI", "TKI_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TKI_FILIAL = '" + xFilial("TKI") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TKJ", "TKJ_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TKJ_FILIAL = '" + xFilial("TKJ") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TKK", "TKK_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TKK_FILIAL = '" + xFilial("TKK") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TMT", "TMT_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TMT_FILIAL = '" + xFilial("TMT") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TMT", "TMT_GRPCI2", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TMT_FILIAL = '" + xFilial("TMT") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TNC", "TNC_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TNC_FILIAL = '" + xFilial("TNC") + "'"})
	aAdd(aChkSql, {"TLG", "TLG_GRUPO", "TNY", "TNY_GRPCID", "",;
					"TLG_FILIAL = '" + xFilial("TLG") + "'", "TNY_FILIAL = '" + xFilial("TNY") + "'"})

	
	//aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclus�o do registro.
	//1 - Chave de pesquisa
	//2 - Alias de pesquisa
	//3 - Ordem de pesquisa
	

	dbSelectArea("TLG")
	dbSetOrder(1)
	If !dbSeek(xFilial("TLG")+"A00") .Or.;
		!dbSeek(xFilial("TLG")+"D00") .Or.;
		!dbSeek(xFilial("TLG")+"H00") .Or. ;
		!dbSeek(xFilial("TLG")+"R00") .Or. ;
		!dbSeek(xFilial("TLG")+"Z00") .Or. ; 
		!dbSeek(xFilial("TLG")+"U07")
		If Type('cPaisLoc') == 'C'
			If cPaisLoc == "BRA"
				//Popula Grupos de CID
				Processa({|| MDTGRUPCID() })
			EndIf
		EndIf
	EndIf

	If FindFunction("MDTRESTRI") .AND. !MDTRESTRI(cPrograma)
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	DbSelectArea("TLG")
	DbSetOrder(1)
	mBrowse( 6, 1, 22, 75, "TLG")

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTGRUPCID
Carrega os grupos do CID 

@author Taina Alberto
@since 28/04/10
@return nil 
/*/
//---------------------------------------------------------------------
Function MDTGRUPCID ()

	Local aGrupo :=  {  {'A00','C�lera'},;
						{'A01','Febres tif�ide e paratif�ide'},;
						{'A02','Outras infec��es por Salmonella'},;
						{'A03','Shiguelose'},;
						{'A04','Outras infec��es intestinais bacterianas'},;
						{'A05','Outras intoxica��es alimentares bacterianas, n�o classificadas em outra parte'},;
						{'A06','Ameb�ase'},;
						{'A07','Outras doen�as intestinais por protozo�rios'},;
						{'A08','Infec��es intestinais virais, outras e as n�o especificadas'},;
						{'A09','Diarr�ia e gastroenterite de origem infecciosa presum�vel'},;
						{'A15','Tuberculose respirat�ria, com confirma��o bacteriol�gica e histol�gica'},;
						{'A16','Tuberculose das vias respirat�rias, sem confirma��o bacteriol�gica ou histol�gica'},;
						{'A17','Tuberculose do sistema nervoso'},;
						{'A18','Tuberculose de outros �rg�os'},;
						{'A19','Tuberculose miliar'},;
						{'A20','Peste'},;
						{'A21','Tularemia'},;
						{'A22','Carb�nculo'},;
						{'A23','Brucelose'},;
						{'A24','Mormo e melioidose'},;
						{'A25','Febres transmitidas por mordedura de rato'},;
						{'A26','Erisipel�ide'},;
						{'A27','Leptospirose'},;
						{'A28','Outras doen�as bacterianas zoon�ticas n�o classificadas em outra parte'},;
						{'A30','Hansen�ase [doen�a de Hansen] [lepra]'},;
						{'A31','Infec��es devidas a outras micobact�rias'},;
						{'A32','Listeriose [lister�ase]'},;
						{'A33','T�tano do rec�m-nascido [neonatal]'},;
						{'A34','T�tano obst�trico'},;
						{'A35','Outros tipos de t�tano'},;
						{'A36','Difteria'},;
						{'A37','Coqueluche'},;
						{'A38','Escarlatina'},;
						{'A39','Infec��o meningog�cica'},;
						{'A40','Septicemia estreptoc�cica'},;
						{'A41','Outras septicemias'},;
						{'A42','Actinomicose'},;
						{'A43','Nocardiose'},;
						{'A44','Bartonelose'},;
						{'A46','Erisipela'},;
						{'A48','Outras doen�as bacterianas n�o classificadas em outra parte'},;
						{'A49','Infec��o bacteriana de localiza��o n�o especificada'},;
						{'A50','S�filis cong�nita'},;
						{'A51','S�filis precoce'},;
						{'A52','S�filis tardia'},;
						{'A53','Outras formas e as n�o especificadas da s�filis'},;
						{'A54','Infec��o gonoc�cica'},;
						{'A55','Linfogranuloma (ven�reo) por clam�dia'},;
						{'A56','Outras infec��es causadas por clam�dias transmitidas por via sexual'},;
						{'A57','Cancro mole'},;
						{'A58','Granuloma inguinal'},;
						{'A59','Tricomon�ase'},;
						{'A60','Infec��es anogenitais pelo v�rus do herpes [herpes simples]'},;
						{'A63','Outras doen�as de transmiss�o predominantemente sexual, n�o classificadas em outra parte'},;
						{'A64','Doen�as sexualmente transmitidas, n�o especificadas'},;
						{'A65','S�filis n�o-ven�rea'},;
						{'A66','Bouba'},;
						{'A67','Pinta [carate]'},;
						{'A68','Febres recorrentes [Borrelioses]'},;
						{'A69','Outras infec��es por espiroquetas'},;
						{'A70','Infec��es causadas por Clam�dia psittaci'},;
						{'A71','Tracoma'},;
						{'A74','Outras doen�as causadas por Clam�dias'},;
						{'A75','Tifo exantem�tico'},;
						{'A77','Febre maculosa [rickettsioses transmitidas por carrapatos]'},;
						{'A78','Febre Q'},;
						{'A79','Outras rickettsioses'},;
						{'A80','Poliomielite aguda'},;
						{'A81','Infec��es por v�rus at�picos do sistema nervoso central'},;
						{'A82','Raiva'},;
						{'A83','Encefalite por v�rus transmitidos por mosquitos'},;
						{'A84','Encefalite por v�rus transmitido por carrapatos'},;
						{'A85','Outras encefalites virais, n�o classificadas em outra parte'},;
						{'A86','Encefalite viral, n�o especificada'},;
						{'A87','Meningite viral'},;
						{'A88','Outras infec��es virais do sistema nervoso central n�o classificadas em outra parte'},;
						{'A89','Infec��es virais n�o especificadas do sistema nervoso central'},;
						{'A90','Dengue [dengue cl�ssico]'},;
						{'A91','Febre hemorr�gica devida ao v�rus do dengue'},;
						{'A92','Outras febres virais transmitidas por mosquitos'},;
						{'A93','Outras febres por v�rus transmitidas por artr�podes n�o classificadas em outra parte'},;
						{'A94','Febre viral transmitida por artr�podes, n�o especificada'},;
						{'A95','Febre amarela'},;
						{'A96','Febre hemorr�gica por arenav�rus'},;
						{'A98','Outras febres hemorr�gicas por v�rus, n�o classificadas em outra parte'},;
						{'A99','Febres hemorr�gicas virais n�o especificadas'},;
						{'B00','Infec��es pelo v�rus do herpes [herpes simples]'},;
						{'B01','Varicela [Catapora]'},;
						{'B02','Herpes zoster [Zona]'},;
						{'B03','Var�ola'},;
						{'B04','Var�ola dos macacos [Monkeypox]'},;
						{'B05','Sarampo'},;
						{'B06','Rub�ola'},;
						{'B07','Verrugas de origem viral'},;
						{'B08','Outras infec��es virais caracterizadas por les�es da pele e das membranas mucosas, n�o classificadas em outra parte'},;
						{'B09','Infec��o viral n�o especificada caracterizada por les�es da pele e membranas mucosas'},;
						{'B15','Hepatite aguda A'},;
						{'B16','Hepatite aguda B'},;
						{'B17','Outras hepatites virais agudas'},;
						{'B18','Hepatite viral cr�nica'},;
						{'B19','Hepatite viral n�o especificada'},;
						{'B20','Doen�a pelo v�rus da imunodefici�ncia humana [HIV], resultando em doen�as infecciosas e parasit�rias'},;
						{'B21','Doen�a pelo v�rus da imunodefici�ncia humana [HIV], resultando em neoplasias malignas'},;
						{'B22','Doen�a pelo v�rus da imunodefici�ncia humana [HIV] resultando em outras doen�as especificadas'},;
						{'B23','Doen�a pelo v�rus da imunodefici�ncia humana [HIV] resultando em outras doen�as'},;
						{'B24','Doen�a pelo v�rus da imunodefici�ncia humana [HIV] n�o especificada'},;
						{'B25','Doen�a por citomegalov�rus'},;
						{'B26','Caxumba [Parotidite epid�mica]'},;
						{'B27','Mononucleose infecciosa'},;
						{'B30','Conjuntivite viral'},;
						{'B33','Outras doen�as por v�rus n�o classificada em outra parte'},;
						{'B34','Doen�as por v�rus, de localiza��o n�o especificada'},;
						{'B35','Dermatofitose'},;
						{'B36','Outras micoses superficiais'},;
						{'B37','Candid�ase'},;
						{'B38','Coccidioidomicose'},;
						{'B39','Histoplasmose'},;
						{'B40','Blastomicose'},;
						{'B41','Paracoccidioidomicose'},;
						{'B42','Esporotricose'},;
						{'B43','Cromomicose e abscesso feomic�tico'},;
						{'B44','Aspergilose'},;
						{'B45','Criptococose'},;
						{'B46','Zigomicose'},;
						{'B47','Micetoma'},;
						{'B48','Outras micoses, n�o classificadas em outra parte'},;
						{'B49','Micose n�o especificada'},;
						{'B50','Mal�ria por Plasmodium falciparum'},;
						{'B51','Mal�ria por Plasmodium vivax'},;
						{'B52','Mal�ria por Plasmodium malariae'},;
						{'B53','Outras formas de mal�ria confirmadas por exames parasitol�gicos'},;
						{'B54','Mal�ria n�o especificada'},;
						{'B55','Leishmaniose'},;
						{'B56','Tripanossom�ase africana'},;
						{'B57','Doen�a de Chagas'},;
						{'B58','Toxoplasmose'},;
						{'B59','Pneumocistose'},;
						{'B60','Outras doen�as devidas a protozo�rios, n�o classificadas em outra parte'},;
						{'B64','Doen�a n�o especificada devida a protozo�rios'},;
						{'B65','Esquistossomose [bilharziose] [Schistosom�ase]'},;
						{'B66','Outras infesta��es por tremat�deos'},;
						{'B67','Equinococose'},;
						{'B68','Infesta��o por Taenia'},;
						{'B69','Cisticercose'},;
						{'B70','Difilobotr�ase e esparganose'},;
						{'B71','Outras infesta��es por cest�ides'},;
						{'B72','Dracont�ase'},;
						{'B73','Oncocercose'},;
						{'B74','Filariose'},;
						{'B75','Triquinose'},;
						{'B76','Ancilostom�ase'},;
						{'B77','Ascarid�ase'},;
						{'B78','Estrongiloid�ase'},;
						{'B79','Tricur�ase'},;
						{'B80','Oxiur�ase'},;
						{'B81','Outras helmint�ases intestinais, n�o classificadas em outra parte'},;
						{'B82','Parasitose intestinal n�o especificada'},;
						{'B83','Outras helmint�ases'},;
						{'B85','Pediculose e ftir�ase'},;
						{'B86','Escabiose [sarna]'},;
						{'B87','Mi�ase'},;
						{'B88','Outras infesta��es'},;
						{'B89','Doen�a parasit�ria n�o especificada'},;
						{'B90','Seq�elas de tuberculose'},;
						{'B91','Seq�elas de poliomielite'},;
						{'B92','Seq�elas de hansen�ase [lepra]'},;
						{'B94','Seq�elas de outras doen�as infecciosas e parasit�rias e das n�o especificadas'},;
						{'B95','Estreptococos e estafilococos como causa de doen�as classificadas em outros cap�tulos'},;
						{'B96','Outros agentes bacterianos, como causa de doen�as classificadas em outros cap�tulos'},;
						{'B97','V�rus como causa de doen�as classificadas em outros cap�tulos'},;
						{'B99','Doen�as infecciosas, outras e as n�o especificadas'},;
						{'C00','Neoplasia maligna do l�bio'},;
						{'C01','Neoplasia maligna da base da l�ngua'},;
						{'C02','Neoplasia maligna de outras partes e de partes n�o especificadas da l�ngua'},;
						{'C03','Neoplasia maligna da gengiva'},;
						{'C04','Neoplasia maligna do assoalho da boca'},;
						{'C05','Neoplasia maligna do palato'},;
						{'C06','Neoplasia maligna de outras partes e de partes n�o especificadas da boca'},;
						{'C07','Neoplasia maligna da gl�ndula par�tida'},;
						{'C08','Neoplasia maligna de outras gl�ndulas salivares maiores e as n�o especificadas'},;
						{'C09','Neoplasia maligna da am�gdala'},;
						{'C10','Neoplasia maligna da orofaringe'},;
						{'C11','Neoplasia maligna da nasofaringe'},;
						{'C12','Neoplasia maligna do seio piriforme'},;
						{'C13','Neoplasia maligna da hipofaringe'},;
						{'C14','Neoplasia maligna de outras localiza��es e de localiza��es mal definida, do l�bio, cavidade oral e faringe'},;
						{'C15','Neoplasia maligna do es�fago'},;
						{'C16','Neoplasia maligna do est�mago'},;
						{'C17','Neoplasia maligna do intestino delgado'},;
						{'C18','Neoplasia maligna do c�lon'},;
						{'C19','Neoplasia maligna da jun��o retossigm�ide'},;
						{'C20','Neoplasia maligna do reto'},;
						{'C21','Neoplasia maligna do �nus e do canal anal'},;
						{'C22','Neoplasia maligna do f�gado e das vias biliares intra-hep�ticas'},;
						{'C23','Neoplasia maligna da ves�cula biliar'},;
						{'C24','Neoplasia maligna de outras partes, e de partes n�o especificadas das vias biliares'},;
						{'C25','Neoplasia maligna do p�ncreas'},;
						{'C26','Neoplasia maligna de outros �rg�os digestivos e de localiza��es mal definidas no aparelho digestivo'},;
						{'C30','Neoplasia maligna da cavidade nasal e do ouvido m�dio'},;
						{'C31','Neoplasia maligna dos seios da face'},;
						{'C32','Neoplasia maligna da laringe'},;
						{'C33','Neoplasia maligna da traqu�ia'},;
						{'C34','Neoplasia maligna dos br�nquios e dos pulm�es'},;
						{'C37','Neoplasia maligna do timo'},;
						{'C38','Neoplasia maligna do cora��o, mediastino e pleura'},;
						{'C39','Neoplasia maligna de outras localiza��es e de localiza��es mal definidas do aparelho respirat�rio e dos �rg�os intrator�cicos'},;
						{'C40','Neoplasia maligna dos ossos e cartilagens articulares dos membros'},;
						{'C41','Neoplasia maligna dos ossos e das cartilagens articulares de outras localiza��es e de localiza��es n�o especificadas'},;
						{'C43','Melanoma maligno da pele'},;
						{'C44','Outras neoplasias malignas da pele'},;
						{'C45','Mesotelioma'},;
						{'C46','Sarcoma de Kaposi'},;
						{'C47','Neoplasia maligna dos nervos perif�ricos e do sistema nervoso aut�nomo'},;
						{'C48','Neoplasia maligna dos tecidos moles do retroperit�nio e do perit�nio'},;
						{'C49','Neoplasia maligna do tecido conjuntivo e de outros tecidos moles'},;
						{'C50','Neoplasia maligna da mama'},;
						{'C51','Neoplasia maligna da vulva'},;
						{'C52','Neoplasia maligna da vagina'},;
						{'C53','Neoplasia maligna do colo do �tero'},;
						{'C54','Neoplasia maligna do corpo do �tero'},;
						{'C55','Neoplasia maligna do �tero, por��o n�o especificada'},;
						{'C56','Neoplasia maligna do ov�rio'},;
						{'C57','Neoplasia maligna de outros �rg�os genitais femininos e dos n�o especificados'},;
						{'C58','Neoplasia maligna da placenta'},;
						{'C60','Neoplasia maligna do p�nis'},;
						{'C61','Neoplasia maligna da pr�stata'},;
						{'C62','Neoplasia maligna dos test�culos'},;
						{'C63','Neoplasia maligna de outros �rg�os genitais masculinos e dos n�o especificados'},;
						{'C64','Neoplasia maligna do rim, exceto pelve renal'},;
						{'C65','Neoplasia maligna da pelve renal'},;
						{'C66','Neoplasia maligna dos ureteres'},;
						{'C67','Neoplasia maligna da bexiga'},;
						{'C68','Neoplasia maligna de outros �rg�os urin�rios e dos n�o especificados'},;
						{'C69','Neoplasia maligna do olho e anexos'},;
						{'C70','Neoplasia maligna das meninges'},;
						{'C71','Neoplasia maligna do enc�falo'},;
						{'C72','Neoplasia maligna da medula espinhal, dos nervos cranianos e de outras partes do sistema nervoso central'},;
						{'C73','Neoplasia maligna da gl�ndula tire�ide'},;
						{'C74','Neoplasia maligna da gl�ndula supra-renal [Gl�ndula adrenal]'},;
						{'C75','Neoplasia maligna de outras gl�ndulas end�crinas e de estruturas relacionadas'},;
						{'C76','Neoplasia maligna de outras localiza��es e de localiza��es mal definidas'},;
						{'C77','Neoplasia maligna secund�ria e n�o especificada dos g�nglios linf�ticos'},;
						{'C78','Neoplasia maligna secund�ria dos �rg�os respirat�rios e digestivos'},;
						{'C79','Neoplasia maligna secund�ria de outras localiza��es'},;
						{'C80','Neoplasia maligna, sem especifica��o de localiza��o'},;
						{'C81','Doen�a de Hodgkin'},;
						{'C82','Linfoma n�o-Hodgkin, folicular (nodular)'},;
						{'C83','Linfoma n�o-Hodgkin difuso'},;
						{'C84','Linfomas de c�lulas T cut�neas e perif�ricas'},;
						{'C85','Linfoma n�o-Hodgkin de outros tipos e de tipo n�o especificado'},;
						{'C88','Doen�as imunoproliferativas malignas'},;
						{'C90','Mieloma m�ltiplo e neoplasias malignas de plasm�citos'},;
						{'C91','Leucemia linf�ide'},;
						{'C92','Leucemia miel�ide'},;
						{'C93','Leucemia monoc�tica'},;
						{'C94','Outras leucemias de c�lulas de tipo especificado'},;
						{'C95','Leucemia de tipo celular n�o especificado'},;
						{'C96','Outras neoplasias malignas e as n�o especificadas dos tecidos linf�tico, hematopo�tico e tecidos correlatos'},;
						{'C97','Neoplasias malignas de localiza��es m�ltiplas independentes (prim�rias)'},;
						{'D00','Carcinoma in situ da cavidade oral, do es�fago e do est�mago'},;
						{'D01','Carcinoma in situ de outros �rg�os digestivos'},;
						{'D02','Carcinoma in situ do ouvido m�dio e do aparelho respirat�rio'},;
						{'D03','Melanoma in situ'},;
						{'D04','Carcinoma in situ da pele'},;
						{'D05','Carcinoma in situ da mama'},;
						{'D06','Carcinoma in situ do colo do �tero (c�rvix)'},;
						{'D07','Carcinoma in situ de outros �rg�os genitais e dos n�o especificados'},;
						{'D09','Carcinoma in situ de outras localiza��es e das n�o especificadas'},;
						{'D10','Neoplasia benigna da boca e da faringe'},;
						{'D11','Neoplasia benigna de gl�ndulas salivares maiores'},;
						{'D12','Neoplasia benigna do c�lon, reto, canal anal e �nus'},;
						{'D13','Neoplasia benigna de outras partes e de partes mal definidas do aparelho digestivo'},;
						{'D14','Neoplasia benigna do ouvido m�dio e do aparelho respirat�rio'},;
						{'D15','Neoplasia benigna de outros �rg�os intrator�cicos e dos n�o especificados'},;
						{'D16','Neoplasia benigna de osso e de cartilagem articular'},;
						{'D17','Neoplasia lipomatosa benigna'},;
						{'D18','Hemangioma e linfangioma de qualquer localiza��o'},;
						{'D19','Neoplasia benigna de tecido mesotelial'},;
						{'D20','Neoplasia benigna de tecido mole do retroperit�nio e do perit�nio'},;
						{'D21','Outras neoplasias benignas do tecido conjuntivo e de outros tecidos moles'},;
						{'D22','Nevos melanoc�ticos'},;
						{'D23','Outras neoplasias benignas da pele'},;
						{'D24','Neoplasia benigna da mama'},;
						{'D25','Leiomioma do �tero'},;
						{'D26','Outras neoplasias benignas do �tero'},;
						{'D27','Neoplasia benigna do ov�rio'},;
						{'D28','Neoplasia benigna de outros �rg�os genitais femininos e de �rg�os n�o especificados'},;
						{'D29','Neoplasia benigna dos �rg�os genitais masculinos'},;
						{'D30','Neoplasia benigna dos �rg�os urin�rios'},;
						{'D31','Neoplasia benigna do olho e anexos'},;
						{'D32','Neoplasia benigna das meninges'},;
						{'D33','Neoplasia benigna do enc�falo e de outras partes do sistema nervoso central'},;
						{'D34','Neoplasia benigna da gl�ndula tire�ide'},;
						{'D35','Neoplasia benigna de outras gl�ndulas end�crinas e das n�o especificadas'},;
						{'D36','Neoplasia benigna de outras localiza��es e de localiza��es n�o especificadas'},;
						{'D37','Neoplasia de comportamento incerto ou desconhecido da cavidade oral e dos �rg�os digestivos'},;
						{'D38','Neoplasia de comportamento incerto ou desconhecido do ouvido m�dio e dos �rg�os respirat�rios e intrator�cicos'},;
						{'D39','Neoplasia de comportamento incerto ou desconhecido dos �rg�os genitais femininos'},;
						{'D40','Neoplasia de comportamento incerto ou desconhecido dos �rg�os genitais masculinos'},;
						{'D41','Neoplasia de comportamento incerto ou desconhecido dos �rg�os urin�rios'},;
						{'D42','Neoplasia de comportamento incerto ou desconhecido das meninges'},;
						{'D43','Neoplasia de comportamento incerto ou desconhecido do enc�falo e do sistema nervoso central'},;
						{'D44','Neoplasia de comportamento incerto ou desconhecido das gl�ndulas end�crinas'},;
						{'D45','Policitemia vera'},;
						{'D46','S�ndromes mielodispl�sicas'},;
						{'D47','Outras neoplasias de comportamento incerto ou desconhecido dos tecidos linf�tico, hematopo�tico e tecidos correlatos'},;
						{'D48','Neoplasia de comportamento incerto ou desconhecido de outras localiza��es e de localiza��es n�o especificadas'},;
						{'D50','Anemia por defici�ncia de ferro'},;
						{'D51','Anemia por defici�ncia de vitamina B12'},;
						{'D52','Anemia por defici�ncia de folato'},;
						{'D53','Outras anemias nutricionais'},;
						{'D55','Anemia devida a transtornos enzim�ticos'},;
						{'D56','Talassemia'},;
						{'D57','Transtornos falciformes'},;
						{'D58','Outras anemias hemol�ticas heredit�rias'},;
						{'D59','Anemia hemol�tica adquirida'},;
						{'D60','Aplasia pura da s�rie vermelha, adquirida [eritroblastopenia]'},;
						{'D61','Outras anemias apl�sticas'},;
						{'D62','Anemia aguda p�s-hemorr�gica'},;
						{'D63','Anemia em doen�as cr�nicas classificadas em outra parte'},;
						{'D64','Outras anemias'},;
						{'D65','Coagula��o intravascular disseminada [s�ndrome de desfibrina��o]'},;
						{'D66','Defici�ncia heredit�ria do fator VIII'},;
						{'D67','Defici�ncia heredit�ria do fator IX'},;
						{'D68','Outros defeitos da coagula��o'},;
						{'D69','P�rpura e outras afec��es hemorr�gicas'},;
						{'D70','Agranulocitose'},;
						{'D71','Transtornos funcionais dos neutr�filos polimorfonucleares'},;
						{'D72','Outros transtornos dos gl�bulos brancos'},;
						{'D73','Doen�as do ba�o'},;
						{'D74','Metemoglobinemia'},;
						{'D75','Outras doen�as do sangue e dos �rg�os hematopo�ticos'},;
						{'D76','Algumas doen�as que envolvem o tecido linforreticular e o sistema reticulohistioc�tico'},;
						{'D77','Outros transtornos do sangue e dos �rg�os hematopo�ticos em doen�as classificadas em outra parte'},;
						{'D80','Imunodefici�ncia com predomin�ncia de defeitos de anticorpos'},;
						{'D81','Defici�ncias imunit�rias combinadas'},;
						{'D82','Imunodefici�ncia associada com outros defeitos "major"'},;
						{'D83','Imunodefici�ncia comum vari�vel'},;
						{'D84','Outras imunodefici�ncias'},;
						{'D86','Sarcoidose'},;
						{'D89','Outros transtornos que comprometem o mecanismo imunit�rio n�o classificados em outra parte'},;
						{'E00','S�ndrome de defici�ncia cong�nita de iodo'},;
						{'E01','Transtornos tireoidianos e afec��es associadas, relacionados � defici�ncia de iodo'},;
						{'E02','Hipotireoidismo subcl�nico por defici�ncia de iodo'},;
						{'E03','Outros hipotireoidismos'},;
						{'E04','Outros b�cios n�o-t�xicos'},;
						{'E05','Tireotoxicose [hipertireoidismo]'},;
						{'E06','Tireoidite'},;
						{'E07','Outros transtornos da tire�ide'},;
						{'E10','Diabetes mellitus insulino-dependente'},;
						{'E11','Diabetes mellitus n�o-insulino-dependente'},;
						{'E12','Diabetes mellitus relacionado com a desnutri��o'},;
						{'E13','Outros tipos especificados de diabetes mellitus'},;
						{'E14','Diabetes mellitus n�o especificado'},;
						{'E15','Coma hipoglic�mico n�o-diab�tico'},;
						{'E16','Outros transtornos da secre��o pancre�tica interna'},;
						{'E20','Hipoparatireoidismo'},;
						{'E21','Hiperparatireoidismo e outros transtornos da gl�ndula paratire�ide'},;
						{'E22','Hiperfun��o da hip�fise'},;
						{'E23','Hipofun��o e outros transtornos da hip�fise'},;
						{'E24','S�ndrome de Cushing'},;
						{'E25','Transtornos adrenogenitais'},;
						{'E26','Hiperaldosteronismo'},;
						{'E27','Outros transtornos da gl�ndula supra-renal'},;
						{'E28','Disfun��o ovariana'},;
						{'E29','Disfun��o testicular'},;
						{'E30','Transtornos da puberdade n�o classificados em outra parte'},;
						{'E31','Disfun��o poliglandular'},;
						{'E32','Doen�as do timo'},;
						{'E34','Outros transtornos end�crinos'},;
						{'E35','Transtornos das gl�ndulas end�crinas em doen�as classificadas em outra parte'},;
						{'E40','Kwashiorkor'},;
						{'E41','Marasmo nutricional'},;
						{'E42','Kwashiorkor marasm�tico'},;
						{'E43','Desnutri��o prot�ico-cal�rica grave n�o especificada'},;
						{'E44','Desnutri��o prot�ico-cal�rica de graus moderado e leve'},;
						{'E45','Atraso do desenvolvimento devido � desnutri��o prot�ico-cal�rica'},;
						{'E46','Desnutri��o prot�ico-cal�rica n�o especificada'},;
						{'E50','Defici�ncia de vitamina A'},;
						{'E51','Defici�ncia de tiamina'},;
						{'E52','Defici�ncia de niacina [pelagra]'},;
						{'E53','Defici�ncia de outras vitaminas do grupo B'},;
						{'E54','Defici�ncia de �cido asc�rbico'},;
						{'E55','Defici�ncia de vitamina D'},;
						{'E56','Outras defici�ncias vitam�nicas'},;
						{'E58','Defici�ncia de c�lcio da dieta'},;
						{'E59','Defici�ncia de sel�nio da dieta'},;
						{'E60','Defici�ncia de zinco da dieta'},;
						{'E61','Defici�ncia de outros elementos nutrientes'},;
						{'E63','Outras defici�ncias nutricionais'},;
						{'E64','Seq�elas de desnutri��o e de outras defici�ncias nutricionais'},;
						{'E65','Adiposidade localizada'},;
						{'E66','Obesidade'},;
						{'E67','Outras formas de hiperalimenta��o'},;
						{'E68','Seq�elas de hiperalimenta��o'},;
						{'E70','Dist�rbios do metabolismo de amino�cidos arom�ticos'},;
						{'E71','Dist�rbios do metabolismo de amino�cidos de cadeia ramificada e do metabolismo dos �cidos graxos'},;
						{'E72','Outros dist�rbios do metabolismo de amino�cidos'},;
						{'E73','Intoler�ncia � lactose'},;
						{'E74','Outros dist�rbios do metabolismo de carboidratos'},;
						{'E75','Dist�rbios do metabolismo de esfingol�pides e outros dist�rbios de dep�sito de l�pides'},;
						{'E76','Dist�rbios do metabolismo do glicosaminoglicano'},;
						{'E77','Dist�rbios do metabolismo de glicoprote�nas'},;
						{'E78','Dist�rbios do metabolismo de lipoprote�nas e outras lipidemias'},;
						{'E79','Dist�rbios do metabolismo de purina e pirimidina'},;
						{'E80','Dist�rbios do metabolismo da porfirina e da bilirrubina'},;
						{'E83','Dist�rbios do metabolismo de minerais'},;
						{'E84','Fibrose c�stica'},;
						{'E85','Amiloidose'},;
						{'E86','Deple��o de volume'},;
						{'E87','Outros transtornos do equil�brio hidroeletrol�tico e �cido-b�sico'},;
						{'E88','Outros dist�rbios metab�licos'},;
						{'E89','Transtornos end�crinos e metab�licos p�s-procedimentos, n�o classificados em outra parte'},;
						{'E90','Transtornos nutricionais e metab�licos em doen�as classificadas em outra parte'},;
						{'F00','Dem�ncia na doen�a de Alzheimer'},;
						{'F01','Dem�ncia vascular'},;
						{'F02','Dem�ncia em outras doen�as classificadas em outra parte'},;
						{'F03','Dem�ncia n�o especificada'},;
						{'F04','S�ndrome amn�sica org�nica n�o induzida pelo �lcool ou por outras subst�ncias psicoativas'},;
						{'F05','Delirium n�o induzido pelo �lcool ou por outras subst�ncias psicoativas'},;
						{'F06','Outros transtornos mentais devidos a les�o e disfun��o cerebral e a doen�a f�sica'},;
						{'F07','Transtornos de personalidade e do comportamento devidos a doen�a, a les�o e a disfun��o cerebral'},;
						{'F09','Transtorno mental org�nico ou sintom�tico n�o especificado'},;
						{'F10','Transtornos mentais e comportamentais devidos ao uso de �lcool'},;
						{'F11','Transtornos mentais e comportamentais devidos ao uso de opi�ceos'},;
						{'F12','Transtornos mentais e comportamentais devidos ao uso de canabin�ides'},;
						{'F13','Transtornos mentais e comportamentais devidos ao uso de sedativos e hipn�ticos'},;
						{'F14','Transtornos mentais e comportamentais devidos ao uso da coca�na'},;
						{'F15','Transtornos mentais e comportamentais devidos ao uso de outros estimulantes, inclusive a cafe�na'},;
						{'F16','Transtornos mentais e comportamentais devidos ao uso de alucin�genos'},;
						{'F17','Transtornos mentais e comportamentais devidos ao uso de fumo'},;
						{'F18','Transtornos mentais e comportamentais devidos ao uso de solventes vol�teis'},;
						{'F19','Transtornos mentais e comportamentais devidos ao uso de m�ltiplas drogas e ao uso de outras subst�ncias psicoativas'},;
						{'F20','Esquizofrenia'},;
						{'F21','Transtorno esquizot�pico'},;
						{'F22','Transtornos delirantes persistentes'},;
						{'F23','Transtornos psic�ticos agudos e transit�rios'},;
						{'F24','Transtorno delirante induzido'},;
						{'F25','Transtornos esquizoafetivos'},;
						{'F28','Outros transtornos psic�ticos n�o-org�nicos'},;
						{'F29','Psicose n�o-org�nica n�o especificada'},;
						{'F30','Epis�dio man�aco'},;
						{'F31','Transtorno afetivo bipolar'},;
						{'F32','Epis�dios depressivos'},;
						{'F33','Transtorno depressivo recorrente'},;
						{'F34','Transtornos de humor [afetivos] persistentes'},;
						{'F38','Outros transtornos do humor [afetivos]'},;
						{'F39','Transtorno do humor [afetivo] n�o especificado'},;
						{'F40','Transtornos f�bico-ansiosos'},;
						{'F41','Outros transtornos ansiosos'},;
						{'F42','Transtorno obsessivo-compulsivo'},;
						{'F43','Rea��es ao "stress" grave e transtornos de adapta��o'},;
						{'F44','Transtornos dissociativos [de convers�o]'},;
						{'F45','Transtornos somatoformes'},;
						{'F48','Outros transtornos neur�ticos'},;
						{'F50','Transtornos da alimenta��o'},;
						{'F51','Transtornos n�o-org�nicos do sono devidos a fatores emocionais'},;
						{'F52','Disfun��o sexual, n�o causada por transtorno ou doen�a org�nica'},;
						{'F53','Transtornos mentais e comportamentais associados ao puerp�rio, n�o classificados em outra parte'},;
						{'F54','Fatores psicol�gicos ou comportamentais associados a doen�a ou a transtornos classificados em outra parte'},;
						{'F55','Abuso de subst�ncias que n�o produzem depend�ncia'},;
						{'F59','S�ndromes comportamentais associados a transtornos das fun��es fisiol�gicas e a fatores f�sicos, n�o especificadas'},;
						{'F60','Transtornos espec�ficos da personalidade'},;
						{'F61','Transtornos mistos da personalidade e outros transtornos da personalidade'},;
						{'F62','Modifica��es duradouras da personalidade n�o atribu�veis a les�o ou doen�a cerebral'},;
						{'F63','Transtornos dos h�bitos e dos impulsos'},;
						{'F64','Transtornos da identidade sexual'},;
						{'F65','Transtornos da prefer�ncia sexual'},;
						{'F66','Transtornos psicol�gicos e comportamentais associados ao desenvolvimento sexual e � sua orienta��o'},;
						{'F68','Outros transtornos da personalidade e do comportamento do adulto'},;
						{'F69','Transtorno da personalidade e do comportamento do adulto, n�o especificado'},;
						{'F70','Retardo mental leve'},;
						{'F71','Retardo mental moderado'},;
						{'F72','Retardo mental grave'},;
						{'F73','Retardo mental profundo'},;
						{'F78','Outro retardo mental'},;
						{'F79','Retardo mental n�o especificado'},;
						{'F80','Transtornos espec�ficos do desenvolvimento da fala e da linguagem'},;
						{'F81','Transtornos espec�ficos do desenvolvimento das habilidades escolares'},;
						{'F82','Transtorno espec�fico do desenvolvimento motor'},;
						{'F83','Transtornos espec�ficos misto do desenvolvimento'},;
						{'F84','Transtornos globais do desenvolvimento'},;
						{'F88','Outros transtornos do desenvolvimento psicol�gico'},;
						{'F89','Transtorno do desenvolvimento psicol�gico n�o especificado'},;
						{'F90','Transtornos hipercin�ticos'},;
						{'F91','Dist�rbios de conduta'},;
						{'F92','Transtornos mistos de conduta e das emo��es'},;
						{'F93','Transtornos emocionais com in�cio especificamente na inf�ncia'},;
						{'F94','Transtornos do funcionamento social com in�cio especificamente durante a inf�ncia ou a adolesc�ncia'},;
						{'F95','Tiques'},;
						{'F98','Outros transtornos comportamentais e emocionais com in�cio habitualmente durante a inf�ncia ou a adolesc�ncia'},;
						{'F99','Transtorno mental n�o especificado em outra parte'},;
						{'G00','Meningite bacteriana n�o classificada em outra parte'},;
						{'G01','Meningite em doen�as bacterianas classificadas em outra parte'},;
						{'G02','Meningite em outras doen�as infecciosas e parasit�rias classificadas em outra parte'},;
						{'G03','Meningite devida a outras causas e a causas n�o especificadas'},;
						{'G04','Encefalite, mielite e encefalomielite'},;
						{'G05','Encefalite, mielite e encefalomielite em doen�as classificadas em outra parte'},;
						{'G06','Abscesso e granuloma intracranianos e intra-raquidianos'},;
						{'G07','Abscesso e granuloma intracranianos e intraspinais em doen�as classificadas em outra parte'},;
						{'G08','Flebite e tromboflebite intracranianas e intra-raquidianas'},;
						{'G09','Seq�elas de doen�as inflamat�rias do sistema nervoso central'},;
						{'G10','Doen�a de Huntington'},;
						{'G11','Ataxia heredit�ria'},;
						{'G12','Atrofia muscular espinal e s�ndromes correlatas'},;
						{'G13','Atrofias sist�micas que afetam principalmente o sistema nervoso central em doen�as classificadas em outra parte'},;
						{'G20','Doen�a de Parkinson'},;
						{'G21','Parkinsonismo secund�rio'},;
						{'G22','Parkinsonismo em doen�as classificadas em outra parte'},;
						{'G23','Outras doen�as degenerativas dos g�nglios da base'},;
						{'G24','Distonia'},;
						{'G25','Outras doen�as extrapiramidais e transtornos dos movimentos'},;
						{'G26','Doen�as extrapiramidais e transtornos dos movimentos em doen�as classificadas em outra parte'},;
						{'G30','Doen�a de Alzheimer'},;
						{'G31','Outras doen�as degenerativas do sistema nervoso n�o classificadas em outra parte'},;
						{'G32','Outros transtornos degenerativos do sistema nervoso em doen�as classificadas em outra parte'},;
						{'G35','Esclerose m�ltipla'},;
						{'G36','Outras desmieliniza��es disseminadas agudas'},;
						{'G37','Outras doen�as desmielinizantes do sistema nervoso central'},;
						{'G40','Epilepsia'},;
						{'G41','Estado de mal epil�ptico'},;
						{'G43','Enxaqueca'},;
						{'G44','Outras s�ndromes de algias cef�licas'},;
						{'G45','Acidentes vasculares cerebrais isqu�micos transit�rios e s�ndromes correlatas'},;
						{'G46','S�ndromes vasculares cerebrais que ocorrem em doen�as cerebrovasculares'},;
						{'G47','Dist�rbios do sono'},;
						{'G50','Transtornos do nervo trig�meo'},;
						{'G51','Transtornos do nervo facial'},;
						{'G52','Transtornos de outros nervos cranianos'},;
						{'G53','Transtornos dos nervos cranianos em doen�as classificadas em outra parte'},;
						{'G54','Transtornos das ra�zes e dos plexos nervosos'},;
						{'G55','Compress�es das ra�zes e dos plexos nervosos em doen�as classificadas em outra parte'},;
						{'G56','Mononeuropatias dos membros superiores'},;
						{'G57','Mononeuropatias dos membros inferiores'},;
						{'G58','Outras mononeuropatias'},;
						{'G59','Mononeuropatias em doen�as classificadas em outra parte'},;
						{'G60','Neuropatia heredit�ria e idiop�tica'},;
						{'G61','Polineuropatia inflamat�ria'},;
						{'G62','Outras polineuropatias'},;
						{'G63','Polineuropatia em doen�as classificadas em outra parte'},;
						{'G64','Outros transtornos do sistema nervoso perif�rico'},;
						{'G70','Miastenia gravis e outros transtornos neuromusculares'},;
						{'G71','Transtornos prim�rios dos m�sculos'},;
						{'G72','Outras miopatias'},;
						{'G73','Transtornos da jun��o mioneural e dos m�sculos em doen�as classificadas em outra parte'},;
						{'G80','Paralisia cerebral'},;
						{'G81','Hemiplegia'},;
						{'G82','Paraplegia e tetraplegia'},;
						{'G83','Outras s�ndromes paral�ticas'},;
						{'G90','Transtornos do sistema nervoso aut�nomo'},;
						{'G91','Hidrocefalia'},;
						{'G92','Encefalopatia t�xica'},;
						{'G93','Outros transtornos do enc�falo'},;
						{'G94','Outros transtornos do enc�falo em doen�as classificadas em outra parte'},;
						{'G95','Outras doen�as da medula espinal'},;
						{'G96','Outros transtornos do sistema nervoso central'},;
						{'G97','Transtornos p�s-procedimento do sistema nervoso n�o classificados em outra parte'},;
						{'G98','Outros transtornos do sistema nervoso n�o classificados em outra parte'},;
						{'G99','Outros transtornos do sistema nervoso em doen�as classificadas em outra parte'},;
						{'H00','Hord�olo e cal�zio'},;
						{'H01','Outras inflama��es da p�lpebra'},;
						{'H02','Outros transtornos da p�lpebra'},;
						{'H03','Transtornos da p�lpebra em doen�as classificadas em outras partes'},;
						{'H04','Transtornos do aparelho lacrimal'},;
						{'H05','Transtornos da �rbita'},;
						{'H06','Transtornos do aparelho lacrimal e da �rbita em doen�as classificadas em outra parte'},;
						{'H10','Conjuntivite'},;
						{'H11','Outros transtornos da conjuntiva'},;
						{'H13','Transtornos da conjuntiva em doen�as classificadas em outra parte'},;
						{'H15','Transtornos da escler�tica'},;
						{'H16','Ceratite'},;
						{'H17','Cicatrizes e opacidades da c�rnea'},;
						{'H18','Outros transtornos da c�rnea'},;
						{'H19','Transtorno da escler�tica e da c�rnea em doen�as classificadas em outra parte'},;
						{'H20','Iridociclite'},;
						{'H21','Outros transtornos da �ris e do corpo ciliar'},;
						{'H22','Transtornos da �ris e do corpo ciliar em doen�as classificadas em outra parte'},;
						{'H25','Catarata senil'},;
						{'H26','Outras cataratas'},;
						{'H27','Outros transtornos do cristalino'},;
						{'H28','Catarata e outros transtornos do cristalino em doen�as classificadas em outra parte'},;
						{'H30','Inflama��o coriorretiniana'},;
						{'H31','Outros transtornos da cor�ide'},;
						{'H32','Transtornos coriorretinianos em doen�as classificadas em outra parte'},;
						{'H33','Descolamentos e defeitos da retina'},;
						{'H34','Oclus�es vasculares da retina'},;
						{'H35','Outros transtornos da retina'},;
						{'H36','Transtornos da retina em doen�as classificadas em outra parte'},;
						{'H40','Glaucoma'},;
						{'H42','Glaucoma em doen�as classificadas em outra parte'},;
						{'H43','Transtornos do humor v�treo'},;
						{'H44','Transtornos do globo ocular'},;
						{'H45','Transtornos do humor v�treo e do globo ocular em doen�as classificadas em outra parte'},;
						{'H46','Neurite �ptica'},;
						{'H47','Outros transtornos do nervo �ptico e das vias �pticas'},;
						{'H48','Transtornos do nervo �ptico [segundo par] e das vias �pticas em doen�as classificadas em outra parte'},;
						{'H49','Estrabismo paral�tico'},;
						{'H50','Outros estrabismos'},;
						{'H51','Outros transtornos do movimento binocular'},;
						{'H52','Transtornos da refra��o e da acomoda��o'},;
						{'H53','Dist�rbios visuais'},;
						{'H54','Cegueira e vis�o subnormal'},;
						{'H55','Nistagmo e outros movimentos irregulares do olho'},;
						{'H57','Outros transtornos do olho e anexos'},;
						{'H58','Outros transtornos do olho e anexos em doen�as classificadas em outra parte'},;
						{'H59','Transtornos do olho e anexos p�s-procedimento n�o classificados em outra parte'},;
						{'H60','Otite externa'},;
						{'H61','Outros transtornos do ouvido externo'},;
						{'H62','Transtornos do ouvido externo em doen�as classificadas em outra parte'},;
						{'H65','Otite m�dia n�o-supurativa'},;
						{'H66','Otite m�dia supurativa e as n�o especificadas'},;
						{'H67','Otite m�dia em doen�as classificadas em outra parte'},;
						{'H68','Salpingite e obstru��o da trompa de Eust�quio'},;
						{'H69','Outros transtornos da trompa de Eust�quio'},;
						{'H70','Mastoidite e afec��es correlatas'},;
						{'H71','Colesteatoma do ouvido m�dio'},;
						{'H72','Perfura��o da membrana do t�mpano'},;
						{'H73','Outros transtornos da membrana do t�mpano'},;
						{'H74','Outros transtornos do ouvido m�dio e da mast�ide'},;
						{'H75','Outros transtornos do ouvido m�dio e da mast�ide em doen�as classificadas em outra parte'},;
						{'H80','Otosclerose'},;
						{'H81','Transtornos da fun��o vestibular'},;
						{'H82','S�ndromes vertiginosas em doen�as classificadas em outra parte'},;
						{'H83','Outros transtornos do ouvido interno'},;
						{'H90','Perda de audi��o por transtorno de condu��o e/ou neuro-sensorial'},;
						{'H91','Outras perdas de audi��o'},;
						{'H92','Otalgia e secre��o auditiva'},;
						{'H93','Outros transtornos do ouvido n�o classificados em outra parte'},;
						{'H94','Outros transtornos do ouvido em doen�as classificadas em outra parte'},;
						{'H95','Transtornos do ouvido e da ap�fise mast�ide p�s-procedimentos, n�o classificados em outra parte'},;
						{'I00','Febre reum�tica sem men��o de comprometimento do cora��o'},;
						{'I01','Febre reum�tica com comprometimento do cora��o'},;
						{'I02','Cor�ia reum�tica'},;
						{'I05','Doen�as reum�ticas da valva mitral'},;
						{'I06','Doen�as reum�ticas da valva a�rtica'},;
						{'I07','Doen�as reum�ticas da valva tric�spide'},;
						{'I08','Doen�as de m�ltiplas valvas'},;
						{'I09','Outras doen�as reum�ticas do cora��o'},;
						{'I10','Hipertens�o essencial (prim�ria)'},;
						{'I11','Doen�a card�aca hipertensiva'},;
						{'I12','Doen�a renal hipertensiva'},;
						{'I13','Doen�a card�aca e renal hipertensiva'},;
						{'I15','Hipertens�o secund�ria'},;
						{'I20','Angina pectoris'},;
						{'I21','Infarto agudo do mioc�rdio'},;
						{'I22','Infarto do mioc�rdio recorrente'},;
						{'I23','Algumas complica��es atuais subseq�entes ao infarto agudo do mioc�rdio'},;
						{'I24','Outras doen�as isqu�micas agudas do cora��o'},;
						{'I25','Doen�a isqu�mica cr�nica do cora��o'},;
						{'I26','Embolia pulmonar'},;
						{'I27','Outras formas de doen�a card�aca pulmonar'},;
						{'I28','Outras doen�as dos vasos pulmonares'},;
						{'I30','Pericardite aguda'},;
						{'I31','Outras doen�as do peric�rdio'},;
						{'I32','Pericardite em doen�as classificadas em outra parte'},;
						{'I33','Endocardite aguda e subaguda'},;
						{'I34','Transtornos n�o-reum�ticos da valva mitral'},;
						{'I35','Transtornos n�o-reum�ticos da valva a�rtica'},;
						{'I36','Transtornos n�o-reum�ticos da valva tric�spide'},;
						{'I37','Transtornos da valva pulmonar'},;
						{'I38','Endocardite de valva n�o especificada'},;
						{'I39','Endocardite e transtornos valvulares card�acos em doen�as classificadas em outra parte'},;
						{'I40','Miocardite aguda'},;
						{'I41','Miocardite em doen�as classificadas em outra parte'},;
						{'I42','Cardiomiopatias'},;
						{'I43','Cardiomiopatia em doen�as classificadas em outra parte'},;
						{'I44','Bloqueio atrioventricular e do ramo esquerdo'},;
						{'I45','Outros transtornos de condu��o'},;
						{'I46','Parada card�aca'},;
						{'I47','Taquicardia parox�stica'},;
						{'I48','Flutter e fibrila��o atrial'},;
						{'I49','Outras arritmias card�acas'},;
						{'I50','Insufici�ncia card�aca'},;
						{'I51','Complica��es de cardiopatias e doen�as card�acas mal definidas'},;
						{'I52','Outras afec��es card�acas em doen�as classificadas em outra parte'},;
						{'I60','Hemorragia subaracn�ide'},;
						{'I61','Hemorragia intracerebral'},;
						{'I62','Outras hemorragias intracranianas n�o-traum�ticas'},;
						{'I63','Infarto cerebral'},;
						{'I64','Acidente vascular cerebral, n�o especificado como hemorr�gico ou isqu�mico'},;
						{'I65','Oclus�o e estenose de art�rias pr�-cerebrais que n�o resultam em infarto cerebral'},;
						{'I66','Oclus�o e estenose de art�rias cerebrais que n�o resultam em infarto cerebral'},;
						{'I67','Outras doen�as cerebrovasculares'},;
						{'I68','Transtornos cerebrovasculares em doen�as classificadas em outra parte'},;
						{'I69','Seq�elas de doen�as cerebrovasculares'},;
						{'I70','Aterosclerose'},;
						{'I71','Aneurisma e dissec��o da aorta'},;
						{'I72','Outros aneurismas'},;
						{'I73','Outras doen�as vasculares perif�ricas'},;
						{'I74','Embolia e trombose arteriais'},;
						{'I77','Outras afec��es das art�rias e arter�olas'},;
						{'I78','Doen�as dos capilares'},;
						{'I79','Transtornos das art�rias, das arter�olas e dos capilares em doen�as classificadas em outra parte'},;
						{'I80','Flebite e tromboflebite'},;
						{'I81','Trombose da veia porta'},;
						{'I82','Outra embolia e trombose venosas'},;
						{'I83','Varizes dos membros inferiores'},;
						{'I84','Hemorr�idas'},;
						{'I85','Varizes esofagianas'},;
						{'I86','Varizes de outras localiza��es'},;
						{'I87','Outros transtornos das veias'},;
						{'I88','Linfadenite inespec�fica'},;
						{'I89','Outros transtornos n�o-infecciosos dos vasos linf�ticos e dos g�nglios linf�ticos'},;
						{'I95','Hipotens�o'},;
						{'I97','Transtornos do aparelho circulat�rio, subseq�entes a procedimentos n�o classificados em outra parte'},;
						{'I98','Outros transtornos do aparelho circulat�rio em doen�as classificadas em outra parte'},;
						{'I99','Outros transtornos do aparelho circulat�rio e os n�o especificados'},;
						{'J00','Nasofaringite aguda [resfriado comum]'},;
						{'J01','Sinusite aguda'},;
						{'J02','Faringite aguda'},;
						{'J03','Amigdalite aguda'},;
						{'J04','Laringite e traque�te agudas'},;
						{'J05','Laringite obstrutiva aguda [crupe] e epiglotite'},;
						{'J06','Infec��es agudas das vias a�reas superiores de localiza��es m�ltiplas e n�o especificadas'},;
						{'J09','Influenza [gripe] devida a v�rus identificado da gripe avi�ria'},;
						{'J10','Influenza devida a outro v�rus da influenza [gripe] identificado'},;
						{'J11','Influenza [gripe] devida a v�rus n�o identificado'},;
						{'J12','Pneumonia viral n�o classificada em outra parte'},;
						{'J13','Pneumonia devida a Streptococcus pneumoniae'},;
						{'J14','Pneumonia devida a Haemophilus infuenzae'},;
						{'J15','Pneumonia bacteriana n�o classificada em outra parte'},;
						{'J16','Pneumonia devida a outros microorganismos infecciosos especificados n�o classificados em outra parte'},;
						{'J17','Pneumonia em doen�as classificadas em outra parte'},;
						{'J18','Pneumonia por microorganismo n�o especificada'},;
						{'J20','Bronquite aguda'},;
						{'J21','Bronquiolite aguda'},;
						{'J22','Infec��es agudas n�o especificada das vias a�reas inferiores'},;
						{'J30','Rinite al�rgica e vasomotora'},;
						{'J31','Rinite, nasofaringite e faringite cr�nicas'},;
						{'J32','Sinusite cr�nica'},;
						{'J33','P�lipo nasal'},;
						{'J34','Outros transtornos do nariz e dos seios paranasais'},;
						{'J35','Doen�as cr�nicas das am�gdalas e das aden�ides'},;
						{'J36','Abscesso periamigdaliano'},;
						{'J37','Laringite e laringotraque�te cr�nicas'},;
						{'J38','Doen�as das cordas vocais e da laringe n�o classificadas em outra parte'},;
						{'J39','Outras doen�as das vias a�reas superiores'},;
						{'J40','Bronquite n�o especificada como aguda ou cr�nica'},;
						{'J41','Bronquite cr�nica simples e a mucopurulenta'},;
						{'J42','Bronquite cr�nica n�o especificada'},;
						{'J43','Enfisema'},;
						{'J44','Outras doen�as pulmonares obstrutivas cr�nicas'},;
						{'J45','Asma'},;
						{'J46','Estado de mal asm�tico'},;
						{'J47','Bronquectasia'},;
						{'J60','Pneumoconiose dos mineiros de carv�o'},;
						{'J61','Pneumoconiose devida a amianto [asbesto] e outras fibras minerais'},;
						{'J62','Pneumoconiose devida a poeira que contenham s�lica'},;
						{'J63','Pneumoconiose devida a outras poeiras inorg�nicas'},;
						{'J64','Pneumoconiose n�o especificada'},;
						{'J65','Pneumoconiose associada com tuberculose'},;
						{'J66','Doen�as das vias a�reas devida a poeiras org�nicas espec�ficas'},;
						{'J67','Pneumonite de hipersensibilidade devida a poeiras org�nicas'},;
						{'J68','Afec��es respirat�rias devidas a inala��o de produtos qu�micos, gases, fuma�as e vapores'},;
						{'J69','Pneumonite devida a s�lidos e l�quidos'},;
						{'J70','Afec��es respirat�rias devida a outros agentes externos'},;
						{'J80','S�ndrome do desconforto respirat�rio do adulto'},;
						{'J81','Edema pulmonar, n�o especificado de outra forma'},;
						{'J82','Eosinofilia pulmonar, n�o classificada em outra parte'},;
						{'J84','Outras doen�as pulmonares intersticiais'},;
						{'J85','Abscesso do pulm�o e do mediastino'},;
						{'J86','Piot�rax'},;
						{'J90','Derrame pleural n�o classificado em outra parte'},;
						{'J91','Derrame pleural em afec��es classificadas em outra parte'},;
						{'J92','Placas pleurais'},;
						{'J93','Pneumot�rax'},;
						{'J94','Outras afec��es pleurais'},;
						{'J95','Afec��es respirat�rias p�s-procedimentos n�o classificadas em outra parte'},;
						{'J96','Insufici�ncia respirat�ria n�o classificada de outra parte'},;
						{'J98','Outros transtornos respirat�rios'},;
						{'J99','Transtornos respirat�rios em doen�as classificadas em outra parte'},;
						{'K00','Dist�rbios do desenvolvimento e da erup��o dos dentes'},;
						{'K01','Dentes inclusos e impactados'},;
						{'K02','C�rie dent�ria'},;
						{'K03','Outras doen�as dos tecidos dent�rios duros'},;
						{'K04','Doen�as da polpa e dos tecidos periapicais'},;
						{'K05','Gengivite e doen�as periodontais'},;
						{'K06','Outros transtornos da gengiva e do rebordo alveolar sem dentes'},;
						{'K07','Anomalias dentofaciais (inclusive a maloclus�o)'},;
						{'K08','Outros transtornos dos dentes e de suas estruturas de sustenta��o'},;
						{'K09','Cistos da regi�o bucal n�o classificados em outra parte'},;
						{'K10','Outras doen�as dos maxilares'},;
						{'K11','Doen�as das gl�ndulas salivares'},;
						{'K12','Estomatite e les�es correlatas'},;
						{'K13','Outras doen�as do l�bio e da mucosa oral'},;
						{'K14','Doen�as da l�ngua'},;
						{'K20','Esofagite'},;
						{'K21','Doen�a de refluxo gastroesof�gico'},;
						{'K22','Outras doen�as do es�fago'},;
						{'K23','Transtornos do es�fago em doen�as classificadas em outra parte'},;
						{'K25','�lcera g�strica'},;
						{'K26','�lcera duodenal'},;
						{'K27','�lcera p�ptica de localiza��o n�o especificada'},;
						{'K28','�lcera gastrojejunal'},;
						{'K29','Gastrite e duodenite'},;
						{'K30','Dispepsia'},;
						{'K31','Outras doen�as do est�mago e do duodeno'},;
						{'K35','Apendicite aguda'},;
						{'K36','Outras formas de apendicite'},;
						{'K37','Apendicite, sem outras especifica��es'},;
						{'K38','Outras doen�as do ap�ndice'},;
						{'K40','H�rnia inguinal'},;
						{'K41','H�rnia femoral'},;
						{'K42','H�rnia umbilical'},;
						{'K43','H�rnia ventral'},;
						{'K44','H�rnia diafragm�tica'},;
						{'K45','Outras h�rnias abdominais'},;
						{'K46','H�rnia abdominal n�o especificada'},;
						{'K50','Doen�a de Crohn [enterite regional]'},;
						{'K51','Colite ulcerativa'},;
						{'K52','Outras gastroenterites e colites n�o-infecciosas'},;
						{'K55','Transtornos vasculares do intestino'},;
						{'K56','�leo paral�tico e obstru��o intestinal sem h�rnia'},;
						{'K57','Doen�a diverticular do intestino'},;
						{'K58','S�ndrome do c�lon irrit�vel'},;
						{'K59','Outros transtornos funcionais do intestino'},;
						{'K60','Fissura e f�stula das regi�es anal e retal'},;
						{'K61','Abscesso das regi�es anal e retal'},;
						{'K62','Outras doen�as do reto e do �nus'},;
						{'K63','Outras doen�as do intestino'},;
						{'K65','Peritonite'},;
						{'K66','Outros transtornos do perit�nio'},;
						{'K67','Comprometimento do perit�nio, em doen�as infecciosas classificadas em outra parte'},;
						{'K70','Doen�a alco�lica do f�gado'},;
						{'K71','Doen�a hep�tica t�xica'},;
						{'K72','Insufici�ncia hep�tica n�o classificada em outra parte'},;
						{'K73','Hepatite cr�nica n�o classificada em outra parte'},;
						{'K74','Fibrose e cirrose hep�ticas'},;
						{'K75','Outras doen�as inflamat�rias do f�gado'},;
						{'K76','Outras doen�as do f�gado'},;
						{'K77','Transtornos do f�gado em doen�as classificadas em outra parte'},;
						{'K80','Colelit�ase'},;
						{'K81','Colecistite'},;
						{'K82','Outras doen�as da ves�cula biliar'},;
						{'K83','Outras doen�as das vias biliares'},;
						{'K85','Pancreatite aguda'},;
						{'K86','Outras doen�as do p�ncreas'},;
						{'K87','Transtornos da ves�cula biliar, das vias biliares e do p�ncreas em doen�as classificadas em outra parte'},;
						{'K90','M�-absor��o intestinal'},;
						{'K91','Transtornos do aparelho digestivo p�s-procedimentos, n�o classificados em outra parte'},;
						{'K92','Outras doen�as do aparelho digestivo'},;
						{'K93','Transtornos de outros �rg�os digestivos em doen�as classificadas em outra parte'},;
						{'L00','S�ndrome da pele escaldada estafiloc�cica do rec�m-nascido'},;
						{'L01','Impetigo'},;
						{'L02','Abscesso cut�neo, fur�nculo e antraz'},;
						{'L03','Celulite (Flegm�o)'},;
						{'L04','Linfadenite aguda'},;
						{'L05','Cisto pilonidal'},;
						{'L08','Outras infec��es localizadas da pele e do tecido subcut�neo'},;
						{'L10','P�nfigo'},;
						{'L11','Outras afec��es acantol�ticas'},;
						{'L12','Penfig�ide'},;
						{'L13','Outras afec��es bolhosas'},;
						{'L14','Afec��es bolhosas em doen�as classificadas em outra parte'},;
						{'L20','Dermatite at�pica'},;
						{'L21','Dermatite seborr�ica'},;
						{'L22','Dermatite das fraldas'},;
						{'L23','Dermatites al�rgicas de contato'},;
						{'L24','Dermatites de contato por irritantes'},;
						{'L25','Dermatite de contato n�o especificada'},;
						{'L26','Dermatite esfoliativa'},;
						{'L27','Dermatite devida a subst�ncias de uso interno'},;
						{'L28','L�quen simples cr�nico e prurigo'},;
						{'L29','Prurido'},;
						{'L30','Outras dermatites'},;
						{'L40','Psor�ase'},;
						{'L41','Parapsor�ase'},;
						{'L42','Pitir�ase r�sea'},;
						{'L43','L�quen plano'},;
						{'L44','Outras afec��es p�pulo-descamativas'},;
						{'L45','Afec��es p�pulo-descamativas em doen�as classificadas em outra parte'},;
						{'L50','Urtic�ria'},;
						{'L51','Eritema polimorfo (eritema multiforme)'},;
						{'L52','Eritema nodoso'},;
						{'L53','Outras afec��es eritematosas'},;
						{'L54','Eritema em doen�as classificadas em outra parte'},;
						{'L55','Queimadura solar'},;
						{'L56','Outras altera��es agudas da pele devidas a radia��o ultravioleta'},;
						{'L57','Altera��es da pele devidas � exposi��o cr�nica � radia��o n�o ionizante'},;
						{'L58','Radiodermatite'},;
						{'L59','Outras afec��es da pele e do tecido subcut�neo relacionadas com a radia��o'},;
						{'L60','Afec��es das unhas'},;
						{'L62','Afec��es das unhas em doen�as classificadas em outra parte'},;
						{'L63','Alop�cia areata'},;
						{'L64','Alop�cia androg�nica'},;
						{'L65','Outras formas n�o cicatriciais da perda de cabelos ou p�los'},;
						{'L66','Alop�cia cicatricial [perda de cabelos ou p�los, cicatricial]'},;
						{'L67','Anormalidades da cor e do ped�culo dos cabelos e dos p�los'},;
						{'L68','Hipertricose'},;
						{'L70','Acne'},;
						{'L71','Ros�cea'},;
						{'L72','Cistos foliculares da pele e do tecido subcut�neo'},;
						{'L73','Outras afec��es foliculares'},;
						{'L74','Afec��es das gl�ndulas sudor�paras �crinas'},;
						{'L75','Afec��es das gl�ndulas sudor�paras ap�crinas'},;
						{'L80','Vitiligo'},;
						{'L81','Outros transtornos da pigmenta��o'},;
						{'L82','Ceratose seborr�ica'},;
						{'L83','Acantose nigricans'},;
						{'L84','Calos e calosidades'},;
						{'L85','Outras formas de espessamento epid�rmico'},;
						{'L86','Ceratodermia em doen�as classificadas em outra parte'},;
						{'L87','Transtornos da elimina��o transepid�rmica'},;
						{'L88','Piodermite gangrenosa'},;
						{'L89','�lcera de dec�bito'},;
						{'L90','Afec��es atr�ficas da pele'},;
						{'L91','Afec��es hipertr�ficas da pele'},;
						{'L92','Afec��es granulomatosas da pele e do tecido subcut�neo'},;
						{'L93','L�pus eritematoso'},;
						{'L94','Outras afec��es localizadas do tecido conjuntivo'},;
						{'L95','Vasculite limitada a pele n�o classificadas em outra parte'},;
						{'L97','�lcera dos membros inferiores n�o classificada em outra parte'},;
						{'L98','Outras afec��es da pele e do tecido subcut�neo n�o classificadas em outra parte'},;
						{'L99','Outras afec��es da pele e do tecido subcut�neo em doen�as classificadas em outra parte'},;
						{'M00','Artrite piog�nica'},;
						{'M01','Infec��es diretas da articula��o em doen�as infecciosas e parasit�rias classificadas em outra parte'},;
						{'M02','Artropatias reacionais'},;
						{'M03','Artropatias p�s-infecciosas e reacionais em doen�as infecciosas classificadas em outra parte'},;
						{'M05','Artrite reumat�ide soro-positiva'},;
						{'M06','Outras artrites reumat�ides'},;
						{'M07','Artropatias psori�sicas e enterop�ticas'},;
						{'M08','Artrite juvenil'},;
						{'M09','Artrite juvenil em doen�as classificadas em outra parte'},;
						{'M10','Gota'},;
						{'M11','Outras artropatias por deposi��o de cristais'},;
						{'M12','Outras artropatias especificadas'},;
						{'M13','Outras artrites'},;
						{'M14','Artropatias em outras doen�as classificadas em outra parte'},;
						{'M15','Poliartrose'},;
						{'M16','Coxartrose [artrose do quadril]'},;
						{'M17','Gonartrose [artrose do joelho]'},;
						{'M18','Artrose da primeira articula��o carpometacarpiana'},;
						{'M19','Outras artroses'},;
						{'M20','Deformidades adquiridas dos dedos das m�os e dos p�s'},;
						{'M21','Outras deformidades adquiridas dos membros'},;
						{'M22','Transtornos da r�tula [patela]'},;
						{'M23','Transtornos internos dos joelhos'},;
						{'M24','Outros transtornos articulares espec�ficos'},;
						{'M25','Outros transtornos articulares n�o classificados em outra parte'},;
						{'M30','Poliarterite nodosa e afec��es correlatas'},;
						{'M31','Outras vasculopatias necrotizantes'},;
						{'M32','L�pus eritematoso disseminado [sist�mico]'},;
						{'M33','Dermatopoliomiosite'},;
						{'M34','Esclerose sist�mica'},;
						{'M35','Outras afec��es sist�micas do tecido conjuntivo'},;
						{'M36','Doen�as sist�micas do tecido conjuntivo em doen�as classificadas em outra parte'},;
						{'M40','Cifose e lordose'},;
						{'M41','Escoliose'},;
						{'M42','Osteocondrose da coluna vertebral'},;
						{'M43','Outras dorsopatias deformantes'},;
						{'M45','Espondilite ancilosante'},;
						{'M46','Outras espondilopatias inflamat�rias'},;
						{'M47','Espondilose'},;
						{'M48','Outras espondilopatias'},;
						{'M49','Espondilopatias em doen�as classificadas em outra parte'},;
						{'M50','Transtornos dos discos cervicais'},;
						{'M51','Outros transtornos de discos intervertebrais'},;
						{'M53','Outras dorsopatias n�o classificadas em outra parte'},;
						{'M54','Dorsalgia'},;
						{'M60','Miosite'},;
						{'M61','Calcifica��o e ossifica��o do m�sculo'},;
						{'M62','Outros transtornos musculares'},;
						{'M63','Transtornos de m�sculo em doen�as classificadas em outra parte'},;
						{'M65','Sinovite e tenossinovite'},;
						{'M66','Ruptura espont�nea de sin�via e de tend�o'},;
						{'M67','Outros transtornos das sin�vias e dos tend�es'},;
						{'M68','Transtorno de sin�vias e de tend�es em doen�as classificadas em outra parte'},;
						{'M70','Transtornos dos tecidos moles relacionados com o uso, uso excessivo e press�o'},;
						{'M71','Outras bursopatias'},;
						{'M72','Transtornos fibrobl�sticos'},;
						{'M73','Transtornos dos tecidos moles em doen�as classificadas em outra parte'},;
						{'M75','Les�es do ombro'},;
						{'M76','Entesopatias dos membros inferiores, excluindo p�'},;
						{'M77','Outras entesopatias'},;
						{'M79','Outros transtornos dos tecidos moles, n�o classificados em outra parte'},;
						{'M80','Osteoporose com fratura patol�gica'},;
						{'M81','Osteoporose sem fratura patol�gica'},;
						{'M82','Osteoporose em doen�as classificadas em outra parte'},;
						{'M83','Osteomal�cia do adulto'},;
						{'M84','Transtornos da continuidade do osso'},;
						{'M85','Outros transtornos da densidade e da estrutura �sseas'},;
						{'M86','Osteomielite'},;
						{'M87','Osteonecrose'},;
						{'M88','Doen�a de Paget do osso (oste�te deformante)'},;
						{'M89','Outros transtornos �sseos'},;
						{'M90','Osteopatias em doen�as classificadas em outra parte'},;
						{'M91','Osteocondrose juvenil do quadril e da pelve'},;
						{'M92','Outras osteocondroses juvenis'},;
						{'M93','Outras osteocondropatias'},;
						{'M94','Outros transtornos das cartilagens'},;
						{'M95','Outras deformidades adquiridas do sistema osteomuscular e do tecido conjuntivo'},;
						{'M96','Transtornos osteomusculares p�s-procedimentos n�o classificados em outra parte'},;
						{'M99','Les�es biomec�nicas n�o classificadas em outra parte'},;
						{'N00','S�ndrome nefr�tica aguda'},;
						{'N01','S�ndrome nefr�tica rapidamente progressiva'},;
						{'N02','Hemat�ria recidivante e persistente'},;
						{'N03','S�ndrome nefr�tica cr�nica'},;
						{'N04','S�ndrome nefr�tica'},;
						{'N05','S�ndrome nefr�tica n�o especificada'},;
						{'N06','Protein�ria isolada com les�o morfol�gica especificada'},;
						{'N07','Nefropatia heredit�ria n�o classificada em outra parte'},;
						{'N08','Transtornos glomerulares em doen�as classificadas em outra parte'},;
						{'N10','Nefrite t�bulo-intersticial aguda'},;
						{'N11','Nefrite t�bulo-intersticial cr�nica'},;
						{'N12','Nefrite t�bulo-intersticial n�o especificada se aguda ou cr�nica'},;
						{'N13','Uropatia obstrutiva e por refluxo'},;
						{'N14','Afec��es tubulares e t�bulo-intersticiais induzidas por drogas ou metais pesados'},;
						{'N15','Outras doen�as renais t�bulo-intersticiais'},;
						{'N16','Transtornos renais t�bulo-intersticiais em doen�as classificadas em outra parte'},;
						{'N17','Insufici�ncia renal aguda'},;
						{'N18','Insufici�ncia renal cr�nica'},;
						{'N19','Insufici�ncia renal n�o especificada'},;
						{'N20','Calculose do rim e do ureter'},;
						{'N21','Calculose do trato urin�rio inferior'},;
						{'N22','Calculose do trato urin�rio inferior em doen�as classificadas em outra parte'},;
						{'N23','C�lica nefr�tica n�o especificada'},;
						{'N25','Transtornos resultantes de fun��o renal tubular alterada'},;
						{'N26','Rim contra�do, n�o especificado'},;
						{'N27','Hipoplasia renal de causa desconhecida'},;
						{'N28','Outros transtornos do rim e do ureter n�o classificado em outra parte'},;
						{'N29','Outros transtornos do rim e do ureter em doen�as classificadas em outra parte'},;
						{'N30','Cistite'},;
						{'N31','Disfun��es neuromusculares da bexiga n�o classificados em outra parte'},;
						{'N32','Outros transtornos da bexiga'},;
						{'N33','Transtornos da bexiga em doen�as classificadas em outra parte'},;
						{'N34','Uretrite e s�ndrome uretral'},;
						{'N35','Estenose da uretra'},;
						{'N36','Outros transtornos da uretra'},;
						{'N37','Transtornos da uretra em doen�as classificadas em outra parte'},;
						{'N39','Outros transtornos do trato urin�rio'},;
						{'N40','Hiperplasia da pr�stata'},;
						{'N41','Doen�as inflamat�rias da pr�stata'},;
						{'N42','Outras afec��es da pr�stata'},;
						{'N43','Hidrocele e espermatocele'},;
						{'N44','Tor��o do test�culo'},;
						{'N45','Orquite e epididimite'},;
						{'N46','Infertilidade masculina'},;
						{'N47','Hipertrofia do prep�cio, fimose e parafimose'},;
						{'N48','Outros transtornos do p�nis'},;
						{'N49','Transtornos inflamat�rios de �rg�os genitais masculinos, n�o classificados em outra parte'},;
						{'N50','Outros transtornos dos �rg�os genitais masculinos'},;
						{'N51','Transtornos dos �rg�os genitais masculinos em doen�as classificadas em outra parte'},;
						{'N60','Displasias mam�rias benignas'},;
						{'N61','Transtornos inflamat�rios da mama'},;
						{'N62','Hipertrofia da mama'},;
						{'N63','N�dulo mam�rio n�o especificado'},;
						{'N64','Outras doen�as da mama'},;
						{'N70','Salpingite e ooforite'},;
						{'N71','Doen�a inflamat�ria do �tero, exceto o colo'},;
						{'N72','Doen�a inflamat�ria do colo do �tero'},;
						{'N73','Outras doen�as inflamat�rias p�lvicas femininas'},;
						{'N74','Transtornos inflamat�rios da pelve feminina em doen�as classificadas em outra parte'},;
						{'N75','Doen�as da gl�ndula de Bartholin'},;
						{'N76','Outras afec��es inflamat�rias da vagina e da vulva'},;
						{'N77','Ulcera��o e inflama��o vulvovaginais em doen�as classificadas em outra parte'},;
						{'N80','Endometriose'},;
						{'N81','Prolapso genital feminino'},;
						{'N82','F�stulas do trato genital feminino'},;
						{'N83','Transtornos n�o-inflamat�rios do ov�rio, da trompa de Fal�pio e do ligamento largo'},;
						{'N84','P�lipo do trato genital feminino'},;
						{'N85','Outros transtornos n�o-inflamat�rios do �tero, exceto do colo do �tero'},;
						{'N86','Eros�o e ectr�pio do colo do �tero'},;
						{'N87','Displasia do colo do �tero'},;
						{'N88','Outros transtornos n�o-inflamat�rios do colo do �tero'},;
						{'N89','Outros transtornos n�o-inflamat�rios da vagina'},;
						{'N90','Outros transtornos n�o-inflamat�rios da vulva e do per�neo'},;
						{'N91','Menstrua��o ausente, escassa e pouco freq�ente'},;
						{'N92','Menstrua��o excessiva, freq�ente e irregular'},;
						{'N93','Outros sangramentos anormais do �tero e da vagina'},;
						{'N94','Dor e outras afec��es associadas com os �rg�os genitais femininos e com o ciclo menstrual'},;
						{'N95','Transtornos da menopausa e da perimenopausa'},;
						{'N96','Abortamento habitual'},;
						{'N97','Infertilidade feminina'},;
						{'N98','Complica��es associadas � fecunda��o artificial'},;
						{'N99','Transtornos do trato geniturin�rio p�s-procedimentos n�o classificados em outra parte'},;
						{'O00','Gravidez ect�pica'},;
						{'O01','Mola hidatiforme'},;
						{'O02','Outros produtos anormais da concep��o'},;
						{'O03','Aborto espont�neo'},;
						{'O04','Aborto por raz�es m�dicas e legais'},;
						{'O05','Outros tipos de aborto'},;
						{'O06','Aborto n�o especificado'},;
						{'O07','Falha de tentativa de aborto'},;
						{'O08','Complica��es conseq�entes a aborto e gravidez ect�pica ou molar'},;
						{'O10','Hipertens�o pr�-existente complicando a gravidez, o parto e o puerp�rio'},;
						{'O11','Dist�rbio hipertensivo pr�-existente com protein�ria superposta'},;
						{'O12','Edema e protein�ria gestacionais [induzidos pela gravidez], sem hipertens�o'},;
						{'O13','Hipertens�o gestacional [induzida pela gravidez] sem protein�ria significativa'},;
						{'O14','Hipertens�o gestacional [induzida pela gravidez] com protein�ria significativa'},;
						{'O15','Ecl�mpsia'},;
						{'O16','Hipertens�o materna n�o especificada'},;
						{'O20','Hemorragia do in�cio da gravidez'},;
						{'O21','V�mitos excessivos na gravidez'},;
						{'O22','Complica��es venosas na gravidez'},;
						{'O23','Infec��es do trato geniturin�rio na gravidez'},;
						{'O24','Diabetes mellitus na gravidez'},;
						{'O25','Desnutri��o na gravidez'},;
						{'O26','Assist�ncia materna por outras complica��es ligadas predominantemente � gravidez'},;
						{'O28','Achados anormais do rastreamento ["screening"] antenatal da m�e'},;
						{'O29','Complica��es de anestesia administrada durante a gravidez'},;
						{'O30','Gesta��o m�ltipla'},;
						{'O31','Complica��es espec�ficas de gesta��o m�ltipla'},;
						{'O32','Assist�ncia prestada � m�e por motivo de apresenta��o anormal, conhecida ou suspeitada, do feto'},;
						{'O33','Assist�ncia prestada � m�e por uma despropor��o conhecida ou suspeita'},;
						{'O34','Assist�ncia prestada � m�e por anormalidade, conhecida ou suspeita, dos �rg�os p�lvicos maternos'},;
						{'O35','Assist�ncia prestada � m�e por anormalidade e les�o fetais, conhecidas ou suspeitadas'},;
						{'O36','Assist�ncia prestada � m�e por outros problemas fetais conhecidos ou suspeitados'},;
						{'O40','Polihidr�mnio'},;
						{'O41','Outros transtornos das membranas e do l�quido amni�tico'},;
						{'O42','Ruptura prematura de membranas'},;
						{'O43','Transtornos da placenta'},;
						{'O44','Placenta pr�via'},;
						{'O45','Descolamento prematuro da placenta [abruptio placentae]'},;
						{'O46','Hemorragia anteparto n�o classificada em outra parte'},;
						{'O47','Falso trabalho de parto'},;
						{'O48','Gravidez prolongada'},;
						{'O60','Trabalho de parto pr�-termo'},;
						{'O61','Falha na indu��o do trabalho de parto'},;
						{'O62','Anormalidades da contra��o uterina'},;
						{'O63','Trabalho de parto prolongado'},;
						{'O64','Obstru��o do trabalho de parto devida � m�-posi��o ou m�-apresenta��o do feto'},;
						{'O65','Obstru��o do trabalho de parto devida a anormalidade p�lvica da m�e'},;
						{'O66','Outras formas de obstru��o do trabalho de parto'},;
						{'O67','Trabalho de parto e parto complicados por hemorragia intraparto n�o classificados em outra parte'},;
						{'O68','Trabalho de parto e parto complicados por sofrimento fetal'},;
						{'O69','Trabalho de parto e parto complicados por anormalidade do cord�o umbilical'},;
						{'O70','Lacera��o do per�neo durante o parto'},;
						{'O71','Outros traumatismos obst�tricos'},;
						{'O72','Hemorragia p�s-parto'},;
						{'O73','Reten��o da placenta e das membranas, sem hemorragias'},;
						{'O74','Complica��es de anestesia durante o trabalho de parto e o parto'},;
						{'O75','Outras complica��es do trabalho de parto e do parto n�o classificadas em outra parte'},;
						{'O80','Parto �nico espont�neo'},;
						{'O81','Parto �nico por f�rceps ou v�cuo-extrator'},;
						{'O82','Parto �nico por cesariana'},;
						{'O83','Outros tipos de parto �nico assistido'},;
						{'O84','Parto m�ltiplo'},;
						{'O85','Infec��o puerperal'},;
						{'O86','Outras infec��es puerperais'},;
						{'O87','Complica��es venosas no puerp�rio'},;
						{'O88','Embolia de origem obst�trica'},;
						{'O89','Complica��es da anestesia administrada durante o puerp�rio'},;
						{'O90','Complica��es do puerp�rio n�o classificadas em outra parte'},;
						{'O91','Infec��es mam�rias associadas ao parto'},;
						{'O92','Outras afec��es da mama e da lacta��o associadas ao parto'},;
						{'O94','Seq�elas de complica��es da gravidez, parto e puerp�rio'},;
						{'O95','Morte obst�trica de causa n�o especificada'},;
						{'O96','Morte, por qualquer causa obst�trica, que ocorre mais de 42 dias, mas menos de 1 ano, ap�s o parto'},;
						{'O97','Morte por seq�elas de causas obst�tricas diretas'},;
						{'O98','Doen�as infecciosas e parasit�rias maternas classific�veis em outra parte mas que compliquem a gravidez, o parto e o puerp�rio'},;
						{'O99','Outras doen�as da m�e, classificadas em outra parte, mas que complicam a gravidez o parto e o puerp�rio'},;
						{'P00','Feto e rec�m-nascido afetados por afec��es maternas, n�o obrigatoriamente relacionadas com a gravidez atual'},;
						{'P01','Feto e rec�m-nascido afetados por complica��es maternas da gravidez'},;
						{'P02','Feto e rec�m-nascido afetados por complica��es da placenta, do cord�o umbilical e das membranas'},;
						{'P03','Feto e rec�m-nascido afetados por outras complica��es do trabalho de parto e do parto'},;
						{'P04','Feto e rec�m-nascido afetados por influ�ncias nocivas transmitidas ao feto via placenta ou leite materno'},;
						{'P05','Crescimento fetal retardado e desnutri��o fetal'},;
						{'P07','Transtornos relacionados com a gesta��o de curta dura��o e peso baixo ao nascer n�o classificados em outra parte'},;
						{'P08','Transtornos relacionados com a gesta��o prolongada e peso elevado ao nascer'},;
						{'P10','Lacera��o intracraniana e hemorragia devidas a traumatismo de parto'},;
						{'P11','Outros traumatismos de parto do sistema nervoso central'},;
						{'P12','Les�o do couro cabeludo devida a traumatismo de parto'},;
						{'P13','Les�es do esqueleto devidas a traumatismo de parto'},;
						{'P14','Les�es ao nascer do sistema nervoso perif�rico'},;
						{'P15','Outros traumatismos de parto'},;
						{'P20','Hip�xia intra-uterina'},;
						{'P21','Asfixia ao nascer'},;
						{'P22','Desconforto (ang�stia) respirat�rio(a) do rec�m-nascido'},;
						{'P23','Pneumonia cong�nita'},;
						{'P24','S�ndrome de aspira��o neonatal'},;
						{'P25','Enfisema intersticial e afec��es correlatas originadas no per�odo perinatal'},;
						{'P26','Hemorragia pulmonar originada no per�odo perinatal'},;
						{'P27','Doen�a respirat�ria cr�nica originada no per�odo perinatal'},;
						{'P28','Outras afec��es respirat�rias originadas no per�odo perinatal'},;
						{'P29','Transtornos cardiovasculares originados no per�odo perinatal'},;
						{'P35','Doen�as virais cong�nitas'},;
						{'P36','Septicemia bacteriana do rec�m-nascido'},;
						{'P37','Outras doen�as infecciosas e parasit�rias cong�nitas'},;
						{'P38','Onfalite do rec�m-nascido com ou sem hemorragia leve'},;
						{'P39','Outras infec��es espec�ficas do per�odo perinatal'},;
						{'P50','Perda sang��nea fetal'},;
						{'P51','Hemorragia umbilical do rec�m-nascido'},;
						{'P52','Hemorragia intracraniana n�o-traum�tica do feto e do rec�m-nascido'},;
						{'P53','Doen�a hemorr�gica do feto e do rec�m-nascido'},;
						{'P54','Outras hemorragias neonatais'},;
						{'P55','Doen�a hemol�tica do feto e do rec�m-nascido'},;
						{'P56','Hidropsia fetal devida a doen�a hemol�tica'},;
						{'P57','Kernicterus'},;
						{'P58','Icter�cia neonatal devida a outras hem�lises excessivas'},;
						{'P59','Icter�cia neonatal devida a outras causas e �s n�o especificadas'},;
						{'P60','Coagula��o intravascular disseminada do feto e do rec�m-nascido'},;
						{'P61','Outros transtornos hematol�gicos perinatais'},;
						{'P70','Transtornos transit�rios do metabolismo dos carboidratos espec�ficos do feto e do rec�m-nascido'},;
						{'P71','Transtornos transit�rios do metabolismo do c�lcio e do magn�sio do per�odo neonatal'},;
						{'P72','Outros transtornos end�crinos transit�rios do per�odo neonatal'},;
						{'P74','Outros dist�rbios eletrol�ticos e metab�licos transit�rios do per�odo neonatal'},;
						{'P75','�leo meconial'},;
						{'P76','Outras obstru��es intestinais do rec�m-nascido'},;
						{'P77','Enterocolite necrotizante do feto e do rec�m-nascido'},;
						{'P78','Outros transtornos do aparelho digestivo do per�odo perinatal'},;
						{'P80','Hipotermia do rec�m-nascido'},;
						{'P81','Outros dist�rbios da regula��o t�rmica do rec�m-nascido'},;
						{'P83','Outras afec��es comprometendo o tegumento espec�ficas do feto e do rec�m-nascido'},;
						{'P90','Convuls�es do rec�m-nascido'},;
						{'P91','Outros dist�rbios da fun��o cerebral do rec�m-nascido'},;
						{'P92','Problemas de alimenta��o do rec�m-nascido'},;
						{'P93','Rea��es e intoxica��es devidas a drogas administradas ao feto e ao rec�m-nascido'},;
						{'P94','Transtornos do t�nus muscular do rec�m-nascido'},;
						{'P95','Morte fetal de causa n�o especificada'},;
						{'P96','Outras afec��es originadas no per�odo perinatal'},;
						{'Q00','Anencefalia e malforma��es similares'},;
						{'Q01','Encefalocele'},;
						{'Q02','Microcefalia'},;
						{'Q03','Hidrocefalia cong�nita'},;
						{'Q04','Outras malforma��es cong�nitas do c�rebro'},;
						{'Q05','Espinha b�fida'},;
						{'Q06','Outras malforma��es cong�nitas da medula espinhal'},;
						{'Q07','Outras malforma��es cong�nitas do sistema nervoso'},;
						{'Q10','Malforma��es cong�nitas das p�lpebras, do aparelho lacrimal e da �rbita'},;
						{'Q11','Anoftalmia, microftalmia e macroftalmia'},;
						{'Q12','Malforma��es cong�nitas do cristalino'},;
						{'Q13','Malforma��es cong�nitas da c�mara anterior do olho'},;
						{'Q14','Malforma��es cong�nitas da c�mara posterior do olho'},;
						{'Q15','Outras malforma��es cong�nitas do olho'},;
						{'Q16','Malforma��es cong�nitas do ouvido causando comprometimento da audi��o'},;
						{'Q17','Outras malforma��es cong�nitas da orelha'},;
						{'Q18','Outras malforma��es cong�nitas da face e do pesco�o'},;
						{'Q20','Malforma��es cong�nitas das c�maras e das comunica��es card�acas'},;
						{'Q21','Malforma��es cong�nitas dos septos card�acos'},;
						{'Q22','Malforma��es cong�nitas das valvas pulmonar e tric�spide'},;
						{'Q23','Malforma��es cong�nitas das valvas a�rtica e mitral'},;
						{'Q24','Outras malforma��es cong�nitas do cora��o'},;
						{'Q25','Malforma��es cong�nitas das grandes art�rias'},;
						{'Q26','Malforma��es cong�nitas das grandes veias'},;
						{'Q27','Outras malforma��es cong�nitas do sistema vascular perif�rico'},;
						{'Q28','Outras malforma��es cong�nitas do aparelho circulat�rio'},;
						{'Q30','Malforma��o cong�nita do nariz'},;
						{'Q31','Malforma��es cong�nitas da laringe'},;
						{'Q32','Malforma��es cong�nitas da traqu�ia e dos br�nquios'},;
						{'Q33','Malforma��es cong�nitas do pulm�o'},;
						{'Q34','Outras malforma��es cong�nitas do aparelho respirat�rio'},;
						{'Q35','Fenda palatina'},;
						{'Q36','Fenda labial'},;
						{'Q37','Fenda labial com fenda palatina'},;
						{'Q38','Outras malforma��es cong�nitas da l�ngua, da boca e da faringe'},;
						{'Q39','Malforma��es cong�nitas do es�fago'},;
						{'Q40','Outras malforma��es cong�nitas do trato digestivo superior'},;
						{'Q41','Aus�ncia, atresia e estenose cong�nita do intestino delgado'},;
						{'Q42','Aus�ncia, atresia e estenose cong�nita do c�lon'},;
						{'Q43','Outras malforma��es cong�nitas do intestino'},;
						{'Q44','Malforma��es cong�nitas da ves�cula biliar, das vias biliares e do f�gado'},;
						{'Q45','Outras malforma��es cong�nitas do aparelho digestivo'},;
						{'Q50','Malforma��es cong�nitas dos ov�rios, das trompas de Fal�pio e dos ligamentos largos'},;
						{'Q51','Malforma��es cong�nitas do �tero e do colo do �tero'},;
						{'Q52','Outras malforma��es cong�nitas dos �rg�os genitais femininos'},;
						{'Q53','Test�culo n�o-descido'},;
						{'Q54','Hiposp�dias'},;
						{'Q55','Outras malforma��es cong�nitas dos �rg�os genitais masculinos'},;
						{'Q56','Sexo indeterminado e pseudo-hermafroditismo'},;
						{'Q60','Agenesia renal e outros defeitos de redu��o do rim'},;
						{'Q61','Doen�as c�sticas do rim'},;
						{'Q62','Anomalias cong�nitas obstrutivas da pelve renal e malforma��es cong�nitas do ureter'},;
						{'Q63','Outras malforma��es cong�nitas do rim'},;
						{'Q64','Outras malforma��es cong�nitas do aparelho urin�rio'},;
						{'Q65','Malforma��es cong�nitas do quadril'},;
						{'Q66','Deformidades cong�nitas do p�'},;
						{'Q67','Deformidades osteomusculares cong�nitas da cabe�a, da face, da coluna e do t�rax'},;
						{'Q68','Outras deformidades osteomusculares cong�nitas'},;
						{'Q69','Polidactilia'},;
						{'Q70','Sindactilia'},;
						{'Q71','Defeitos, por redu��o, do membro superior'},;
						{'Q72','Defeitos, por redu��o, do membro inferior'},;
						{'Q73','Defeitos por redu��o de membro n�o especificado'},;
						{'Q74','Outras malforma��es cong�nitas dos membros'},;
						{'Q75','Outras malforma��es cong�nitas dos ossos do cr�nio e da face'},;
						{'Q76','Malforma��es cong�nitas da coluna vertebral e dos ossos do t�rax'},;
						{'Q77','Osteocondrodisplasia com anomalias de crescimento dos ossos longos e da coluna vertebral'},;
						{'Q78','Outras osteocondrodisplasias'},;
						{'Q79','Malforma��es cong�nitas do sistema osteomuscular n�o classificadas em outra parte'},;
						{'Q80','Ictiose cong�nita'},;
						{'Q81','Epiderm�lise bolhosa'},;
						{'Q82','Outras malforma��es cong�nitas da pele'},;
						{'Q83','Malforma��es cong�nitas da mama'},;
						{'Q84','Outras malforma��es cong�nitas do tegumento'},;
						{'Q85','Facomatoses n�o classificadas em outra parte'},;
						{'Q86','S�ndromes com malforma��es cong�nitas devidas a causas ex�genas conhecidas, n�o classificadas em outra parte'},;
						{'Q87','Outras s�ndromes com malforma��es cong�nitas que acometem m�ltiplos sistemas'},;
						{'Q89','Outras malforma��es cong�nitas n�o classificadas em outra parte'},;
						{'Q90','S�ndrome de Down'},;
						{'Q91','S�ndrome de Edwards e s�ndrome de Patau'},;
						{'Q92','Outras trissomias e trissomias parciais dos autossomos, n�o classificadas em outra parte'},;
						{'Q93','Monossomias e dele��es dos autossomos, n�o classificadas em outra parte'},;
						{'Q95','Rearranjos equilibrados e marcadores estruturais, n�o classificados em outra parte'},;
						{'Q96','S�ndrome de Turner'},;
						{'Q97','Outras anomalias dos cromossomos sexuais, fen�tipo feminino, n�o classificadas em outra parte'},;
						{'Q98','Outras anomalias dos cromossomos sexuais, fen�tipo masculino, n�o classificadas em outra parte'},;
						{'Q99','Outras anomalias dos cromossomos, n�o classificadas em outra parte'},;
						{'R00','Anormalidades do batimento card�aco'},;
						{'R01','Sopros e outros ru�dos card�acos'},;
						{'R02','Gangrena n�o classificada em outra parte'},;
						{'R03','Valor anormal da press�o arterial sem diagn�stico'},;
						{'R04','Hemorragia das vias respirat�rias'},;
						{'R05','Tosse'},;
						{'R06','Anormalidades da respira��o'},;
						{'R07','Dor de garganta e no peito'},;
						{'R09','Outros sintomas e sinais relativos aos aparelhos circulat�rio e respirat�rio'},;
						{'R10','Dor abdominal e p�lvica'},;
						{'R11','N�usea e v�mitos'},;
						{'R12','Pirose'},;
						{'R13','Disfagia'},;
						{'R14','Flatul�ncia e afec��es correlatas'},;
						{'R15','Incontin�ncia fecal'},;
						{'R16','Hepatomegalia e esplenomegalia n�o classificadas em outra parte'},;
						{'R17','Icter�cia n�o especificada'},;
						{'R18','Ascite'},;
						{'R19','Outros sintomas e sinais relativos ao aparelho digestivo e ao abdome'},;
						{'R20','Dist�rbios da sensibilidade cut�nea'},;
						{'R21','Eritema e outras erup��es cut�neas n�o especificadas'},;
						{'R22','Tumefa��o, massa ou tumora��o localizadas da pele e do tecido subcut�neo'},;
						{'R23','Outras altera��es cut�neas'},;
						{'R25','Movimentos involunt�rios anormais'},;
						{'R26','Anormalidades da marcha e da mobilidade'},;
						{'R27','Outros dist�rbios da coordena��o'},;
						{'R29','Outros sintomas e sinais relativos aos sistemas nervoso e osteomuscular'},;
						{'R30','Dor associada � mic��o'},;
						{'R31','Hemat�ria n�o especificada'},;
						{'R32','Incontin�ncia urin�ria n�o especificada'},;
						{'R33','Reten��o urin�ria'},;
						{'R34','An�ria e olig�ria'},;
						{'R35','Poli�ria'},;
						{'R36','Secre��o uretral'},;
						{'R39','Outros sintomas e sinais relativos ao aparelho urin�rio'},;
						{'R40','Sonol�ncia, estupor e coma'},;
						{'R41','Outros sintomas e sinais relativos � fun��o cognitiva e � consci�ncia'},;
						{'R42','Tontura e instabilidade'},;
						{'R43','Dist�rbios do olfato e do paladar'},;
						{'R44','Outros sintomas e sinais relativos �s sensa��es e �s percep��es gerais'},;
						{'R45','Sintomas e sinais relativos ao estado emocional'},;
						{'R46','Sintomas e sinais relativos � apar�ncia e ao comportamento'},;
						{'R47','Dist�rbios da fala n�o classificados em outra parte'},;
						{'R48','Dislexia e outras disfun��es simb�licas, n�o classificadas em outra parte'},;
						{'R49','Dist�rbios da voz'},;
						{'R50','Febre de origem desconhecida e de outras origens'},;
						{'R51','Cefal�ia'},;
						{'R52','Dor n�o classificada em outra parte'},;
						{'R53','Mal estar, fadiga'},;
						{'R54','Senilidade'},;
						{'R55','S�ncope e colapso'},;
						{'R56','Convuls�es, n�o classificadas em outra parte'},;
						{'R57','Choque n�o classificado em outra parte'},;
						{'R58','Hemorragia n�o classificada em outra parte'},;
						{'R59','Aumento de volume dos g�nglios linf�ticos'},;
						{'R60','Edema n�o classificado em outra parte'},;
						{'R61','Hiperidrose'},;
						{'R62','Retardo do desenvolvimento fisiol�gico normal'},;
						{'R63','Sintomas e sinais relativos � ingest�o de alimentos e l�quidos'},;
						{'R64','Caquexia'},;
						{'R68','Outros sintomas e sinais gerais'},;
						{'R69','Causas desconhecidas e n�o especificadas de morbidade'},;
						{'R70','Velocidade de hemossedimenta��o elevada e outras anormalidades da viscosidade plasm�tica'},;
						{'R71','Anormalidade das hem�cias'},;
						{'R72','Anormalidade dos leuc�citos n�o classificada em outra parte'},;
						{'R73','Aumento da glicemia'},;
						{'R74','Anormalidades dos n�veis de enzimas s�ricas'},;
						{'R75','Evid�ncia laboratorial do v�rus da imunodefici�ncia humana [HIV]'},;
						{'R76','Outros achados imunol�gicos anormais no soro'},;
						{'R77','Outras anormalidades das prote�nas plasm�ticas'},;
						{'R78','Presen�a de drogas e de outras subst�ncias normalmente n�o encontradas no sangue'},;
						{'R79','Outros achados anormais de exames qu�micos do sangue'},;
						{'R80','Protein�ria isolada'},;
						{'R81','Glicos�ria'},;
						{'R82','Outros achados anormais na urina'},;
						{'R83','Achados anormais no l�quido cefalorraquidiano'},;
						{'R84','Achados anormais de material proveniente dos �rg�os respirat�rios e do t�rax'},;
						{'R85','Achados anormais de material proveniente dos �rg�os digestivos e da cavidade abdominal'},;
						{'R86','Achados anormais de material proveniente dos �rg�os genitais masculinos'},;
						{'R87','Achados anormais de material proveniente dos �rg�os genitais femininos'},;
						{'R89','Achados anormais de material proveniente de outros �rg�os, aparelhos, sistemas e tecidos'},;
						{'R90','Resultados anormais de exames para diagn�stico por imagem do sistema nervoso central'},;
						{'R91','Achados anormais, de exames para diagn�stico por imagem, do pulm�o'},;
						{'R92','Achados anormais, de exames para diagn�stico por imagem, da mama'},;
						{'R93','Achados anormais de exames para diagn�stico por imagem de outras estruturas do corpo'},;
						{'R94','Resultados anormais de estudos de fun��o'},;
						{'R95','S�ndrome da morte s�bita na inf�ncia'},;
						{'R96','Outras mortes s�bitas de causa desconhecida'},;
						{'R98','Morte sem assist�ncia'},;
						{'R99','Outras causas mal definidas e as n�o especificadas de mortalidade'},;
						{'S00','Traumatismo superficial da cabe�a'},;
						{'S01','Ferimento da cabe�a'},;
						{'S02','Fratura do cr�nio e dos ossos da face'},;
						{'S03','Luxa��o, entorse ou distens�o das articula��es e dos ligamentos da cabe�a'},;
						{'S04','Traumatismo dos nervos cranianos'},;
						{'S05','Traumatismo do olho e da �rbita ocular'},;
						{'S06','Traumatismo intracraniano'},;
						{'S07','Les�es por esmagamento da cabe�a'},;
						{'S08','Amputa��o traum�tica de parte da cabe�a'},;
						{'S09','Outros traumatismos da cabe�a e os n�o especificados'},;
						{'S10','Traumatismo superficial do pesco�o'},;
						{'S11','Ferimento do pesco�o'},;
						{'S12','Fratura do pesco�o'},;
						{'S13','Luxa��o, entorse ou distens�o das articula��es e dos ligamentos do pesco�o'},;
						{'S14','Traumatismo de nervos e da medula espinhal ao n�vel cervical'},;
						{'S15','Traumatismo dos vasos sang��neos ao n�vel do pesco�o'},;
						{'S16','Traumatismo de tend�es e de m�sculos do pesco�o'},;
						{'S17','Les�es por esmagamento do pesco�o'},;
						{'S18','Amputa��o traum�tica ao n�vel do pesco�o'},;
						{'S19','Outros traumatismos do pesco�o e os n�o especificados'},;
						{'S20','Traumatismo superficial do t�rax'},;
						{'S21','Ferimento do t�rax'},;
						{'S22','Fratura de costela(s), esterno e coluna tor�cica'},;
						{'S23','Luxa��o, entorse e distens�o de articula��es e dos ligamentos do t�rax'},;
						{'S24','Traumatismos de nervos e da medula espinhal ao n�vel do t�rax'},;
						{'S25','Traumatismo de vasos sang��neos do t�rax'},;
						{'S26','Traumatismo do cora��o'},;
						{'S27','Traumatismo de outros �rg�os intrator�cicos e dos n�o especificados'},;
						{'S28','Les�o por esmagamento do t�rax e amputa��o traum�tica de parte do t�rax'},;
						{'S29','Outros traumatismos do t�rax e os n�o especificados'},;
						{'S30','Traumatismo superficial do abdome, do dorso e da pelve'},;
						{'S31','Ferimento do abdome, do dorso e da pelve'},;
						{'S32','Fratura da coluna lombar e da pelve'},;
						{'S33','Luxa��o, entorse ou distens�o das articula��es e dos ligamentos da coluna lombar e da pelve'},;
						{'S34','Traumatismo dos nervos e da medula lombar ao n�vel do abdome, do dorso e da pelve'},;
						{'S35','Traumatismo de vasos sang��neos ao n�vel do abdome, do dorso e da pelve'},;
						{'S36','Traumatismo de �rg�os intra-abdominais'},;
						{'S37','Traumatismo do aparelho urin�rio e de �rg�os p�lvicos'},;
						{'S38','Les�o por esmagamento e amputa��o traum�tica de parte do abdome, do dorso e da pelve'},;
						{'S39','Outros traumatismos e os n�o especificados do abdome, do dorso e da pelve'},;
						{'S40','Traumatismo superficial do ombro e do bra�o'},;
						{'S41','Ferimento do ombro e do bra�o'},;
						{'S42','Fratura do ombro e do bra�o'},;
						{'S43','Luxa��o, entorse e distens�o das articula��es e dos ligamentos da cintura escapular'},;
						{'S44','Traumatismo de nervos ao n�vel do ombro e do bra�o'},;
						{'S45','Traumatismo dos vasos sang��neos ao n�vel do ombro e do bra�o'},;
						{'S46','Traumatismo de tend�o e m�sculo ao n�vel do ombro e do bra�o'},;
						{'S47','Les�o por esmagamento do ombro e do bra�o'},;
						{'S48','Amputa��o traum�tica do ombro e do bra�o'},;
						{'S49','Outros traumatismos e os n�o especificados do ombro e do bra�o'},;
						{'S50','Traumatismo superficial do cotovelo e do antebra�o'},;
						{'S51','Ferimento do antebra�o'},;
						{'S52','Fratura do antebra�o'},;
						{'S53','Luxa��o, entorse e distens�o das articula��es e dos ligamentos do cotovelo'},;
						{'S54','Traumatismo de nervos ao n�vel do antebra�o'},;
						{'S55','Traumatismo de vasos sang��neos ao n�vel do antebra�o'},;
						{'S56','Traumatismo do m�sculo e tend�o ao n�vel do antebra�o'},;
						{'S57','Les�o por esmagamento do antebra�o'},;
						{'S58','Amputa��o traum�tica do cotovelo e do antebra�o'},;
						{'S59','Outros traumatismos do antebra�o e os n�o especificados'},;
						{'S60','Traumatismo superficial do punho e da m�o'},;
						{'S61','Ferimento do punho e da m�o'},;
						{'S62','Fratura ao n�vel do punho e da m�o'},;
						{'S63','Luxa��o, entorse e distens�o das articula��es e dos ligamentos ao n�vel do punho e da m�o'},;
						{'S64','Traumatismo de nervos ao n�vel do punho e da m�o'},;
						{'S65','Traumatismo de vasos sang��neos ao n�vel do punho e da m�o'},;
						{'S66','Traumatismo de m�sculo e tend�o ao n�vel do punho e da m�o'},;
						{'S67','Les�o por esmagamento do punho e da m�o'},;
						{'S68','Amputa��o traum�tica ao n�vel do punho e da m�o'},;
						{'S69','Outros traumatismos e os n�o especificados do punho e da m�o'},;
						{'S70','Traumatismo superficial do quadril e da coxa'},;
						{'S71','Ferimento do quadril e da coxa'},;
						{'S72','Fratura do f�mur'},;
						{'S73','Luxa��o, entorse e distens�o da articula��o e dos ligamentos do quadril'},;
						{'S74','Traumatismo de nervos ao n�vel do quadril e da coxa'},;
						{'S75','Traumatismo de vasos sang��neos ao n�vel do quadril e da coxa'},;
						{'S76','Traumatismo de m�sculo e de tend�o ao n�vel do quadril e da coxa'},;
						{'S77','Les�o por esmagamento do quadril e da coxa'},;
						{'S78','Amputa��o traum�tica do quadril e da coxa'},;
						{'S79','Outros traumatismos e os n�o especificados do quadril e da coxa'},;
						{'S80','Traumatismo superficial da perna'},;
						{'S81','Ferimento da perna'},;
						{'S82','Fratura da perna, incluindo tornozelo'},;
						{'S83','Luxa��o, entorse e distens�o das articula��es e dos ligamentos do joelho'},;
						{'S84','Traumatismo de nervos perif�ricos da perna'},;
						{'S85','Traumatismo de vasos sang��neos da perna'},;
						{'S86','Traumatismos de m�sculo e de tend�o ao n�vel da perna'},;
						{'S87','Traumatismo por esmagamento da perna'},;
						{'S88','Amputa��o traum�tica da perna'},;
						{'S89','Outros traumatismos e os n�o especificados da perna'},;
						{'S90','Traumatismo superficial do tornozelo e do p�'},;
						{'S91','Ferimentos do tornozelo e do p�'},;
						{'S92','Fratura do p� (exceto do tornozelo)'},;
						{'S93','Luxa��o, entorse e distens�o das articula��es e dos ligamentos ao n�vel do tornozelo e do p�'},;
						{'S94','Traumatismo dos nervos ao n�vel do tornozelo e do p�'},;
						{'S95','Traumatismo de vasos sang��neos ao n�vel do tornozelo e do p�'},;
						{'S96','Traumatismos do m�sculo e tend�o ao n�vel do tornozelo e do p�'},;
						{'S97','Les�o por esmagamento do tornozelo e do p�'},;
						{'S98','Amputa��o traum�tica do tornozelo e do p�'},;
						{'S99','Outros traumatismos e os n�o especificados do tornozelo e do p�'},;
						{'T00','Traumatismos superficiais envolvendo m�ltiplas regi�es do corpo'},;
						{'T01','Ferimentos envolvendo m�ltiplas regi�es do corpo'},;
						{'T02','Fraturas envolvendo m�ltiplas regi�es do corpo'},;
						{'T03','Luxa��es, entorses e distens�es envolvendo regi�es m�ltiplas do corpo'},;
						{'T04','Traumatismos por esmagamento envolvendo m�ltiplas regi�es do corpo'},;
						{'T05','Amputa��es traum�ticas envolvendo m�ltiplas regi�es do corpo'},;
						{'T06','Outros traumatismos envolvendo regi�es m�ltiplas do corpo, n�o classificados em outra parte'},;
						{'T07','Traumatismos m�ltiplos n�o especificados'},;
						{'T08','Fratura da coluna, n�vel n�o especificado'},;
						{'T09','Outros traumatismos de coluna e tronco, n�vel n�o especificado'},;
						{'T10','Fratura do membro superior, n�vel n�o especificado'},;
						{'T11','Outros traumatismos de membro superior, n�vel n�o especificado'},;
						{'T12','Fratura do membro inferior, n�vel n�o especificado'},;
						{'T13','Outros traumatismos de membro inferior, n�vel n�o especificado'},;
						{'T14','Traumatismo de regi�o n�o especificada do corpo'},;
						{'T15','Corpo estranho na parte externa do olho'},;
						{'T16','Corpo estranho no ouvido'},;
						{'T17','Corpo estranho no trato respirat�rio'},;
						{'T18','Corpo estranho no aparelho digestivo'},;
						{'T19','Corpo estranho no trato geniturin�rio'},;
						{'T20','Queimadura e corros�o da cabe�a e pesco�o'},;
						{'T21','Queimadura e corros�o do tronco'},;
						{'T22','Queimadura e corros�o do ombro e membro superior, exceto punho e m�o'},;
						{'T23','Queimadura e corros�o do punho e da m�o'},;
						{'T24','Queimadura e corros�o do quadril e membro inferior, exceto tornozelo e do p�'},;
						{'T25','Queimadura e corros�o do tornozelo e do p�'},;
						{'T26','Queimadura e corros�o limitadas ao olho e seus anexos'},;
						{'T27','Queimadura e corros�o do trato respirat�rio'},;
						{'T28','Queimadura e corros�o de outros �rg�os internos'},;
						{'T29','Queimaduras e corros�es de m�ltiplas regi�es do corpo'},;
						{'T30','Queimadura e corros�o, parte n�o especificada do corpo'},;
						{'T31','Queimaduras classificadas segundo a extens�o da superf�cie corporal atingida'},;
						{'T32','Corros�es classificadas segundo a extens�o da superf�cie corporal atingida'},;
						{'T33','Geladura superficial'},;
						{'T34','Geladura com necrose de tecidos'},;
						{'T35','Geladura de m�ltiplas partes do corpo e das n�o especificadas'},;
						{'T36','Intoxica��o por antibi�ticos sist�micos'},;
						{'T37','Intoxica��o por outras subst�ncias antiinfecciosas ou antiparasit�rias sist�micas'},;
						{'T38','Intoxica��o por horm�nios, seus substitutos sint�ticos e seus antagonistas n�o classificados em outra parte'},;
						{'T39','Intoxica��o por analg�sicos, antipir�ticos e anti-reum�ticos n�o-opi�ceos'},;
						{'T40','Intoxica��o por narc�ticos e psicodisl�pticos [alucin�genos]'},;
						{'T41','Intoxica��o por anest�sicos e gases terap�uticos'},;
						{'T42','Intoxica��o por antiepil�pticos, sedativos-hipn�ticos e antiparkinsonianos'},;
						{'T43','Intoxica��o por drogas psicotr�picas n�o classificadas em outra parte'},;
						{'T44','Intoxica��o por drogas que afetam principalmente o sistema nervoso aut�nomo'},;
						{'T45','Intoxica��o por subst�ncias de a��o essencialmente sist�mica e subst�ncias hematol�gicas, n�o classificadas em outra parte'},;
						{'T46','Intoxica��o por subst�ncias que atuam primariamente sobre o aparelho circulat�rio'},;
						{'T47','Intoxica��o por subst�ncias que atuam primariamente sobre o aparelho gastrointestinal'},;
						{'T48','Intoxica��o por subst�ncias que atuam primariamente sobre os m�sculos lisos e esquel�ticos e sobre o aparelho respirat�rio'},;
						{'T49','Intoxica��o por subst�ncias de uso t�pico que atuam primariamente sobre a pele e as mucosas e por medicamentos utilizados em oftalmologia, otorrinolaringologia e odontologia'},;
						{'T50','Intoxica��o por diur�ticos e outras drogas, medicamentos e subst�ncias biol�gicas e as n�o especificadas'},;
						{'T51','Efeito t�xico do �lcool'},;
						{'T52','Efeito t�xico de solventes org�nicos'},;
						{'T53','Efeito t�xico de derivados halog�nicos de hidrocarbonetos alif�ticos e arom�ticos'},;
						{'T54','Efeito t�xico de corrosivos'},;
						{'T55','Efeito t�xico de sab�es e detergentes'},;
						{'T56','Efeito t�xico de metais'},;
						{'T57','Efeito t�xico de outras subst�ncias inorg�nicas'},;
						{'T58','Efeito t�xico do mon�xido de carbono'},;
						{'T59','Efeito t�xico de outros gases, fuma�as e vapores'},;
						{'T60','Efeito t�xico de pesticidas'},;
						{'T61','Efeito t�xico de subst�ncias nocivas consumidas como fruto do mar'},;
						{'T62','Efeito t�xico de outras subst�ncias nocivas ingeridas como alimento'},;
						{'T63','Efeito t�xico de contato com animais venenosos'},;
						{'T64','Efeito t�xico da aflatoxina e de outras micotoxinas contaminantes de alimentos'},;
						{'T65','Efeito t�xico de outras subst�ncias e as n�o especificadas'},;
						{'T66','Efeitos n�o especificados de radia��o'},;
						{'T67','Efeitos do calor e da luz'},;
						{'T68','Hipotermia'},;
						{'T69','Outros efeitos da temperatura reduzida'},;
						{'T70','Efeitos da press�o atmosf�rica e da press�o da �gua'},;
						{'T71','Asfixia'},;
						{'T73','Efeitos de outras priva��es'},;
						{'T74','S�ndromes de maus tratos'},;
						{'T75','Efeitos de outras causas externas'},;
						{'T78','Efeitos adversos n�o classificados em outra parte'},;
						{'T79','Algumas complica��es precoces dos traumatismos n�o classificadas em outra parte'},;
						{'T80','Complica��es conseq�entes � infus�o, transfus�o ou inje��o terap�utica'},;
						{'T81','Complica��es de procedimentos n�o classificadas em outra parte'},;
						{'T82','Complica��es de dispositivos prot�ticos, implantes e enxertos card�acos e vasculares'},;
						{'T83','Complica��es de dispositivos prot�ticos, implantes e enxertos geniturin�rios internos'},;
						{'T84','Complica��es de dispositivos prot�ticos, implantes e enxertos ortop�dicos internos'},;
						{'T85','Complica��es de outros dispositivos prot�ticos, implantes e enxertos internos'},;
						{'T86','Falha e rejei��o de �rg�os e tecidos transplantados'},;
						{'T87','Complica��es pr�prias de reimplante e amputa��o'},;
						{'T88','Outras complica��es de cuidados m�dicos e cir�rgicos n�o classificadas em outra parte'},;
						{'T90','Seq�elas de traumatismo da cabe�a'},;
						{'T91','Seq�elas de traumatismos do pesco�o e do tronco'},;
						{'T92','Seq�elas de traumatismos do membro superior'},;
						{'T93','Seq�elas de traumatismos do membro inferior'},;
						{'T94','Seq�elas de traumatismos envolvendo m�ltiplas regi�es do corpo e as n�o especificadas'},;
						{'T95','Seq�elas de queimaduras, corros�es e geladuras'},;
						{'T96','Seq�elas de intoxica��o por drogas, medicamentos e subst�ncias biol�gicas'},;
						{'T97','Seq�elas de efeitos t�xicos de subst�ncias de origem predominantemente n�o-medicinal'},;
						{'T98','Seq�elas de outros efeitos de causas externas e dos n�o especificados'},;
						{'V01','Pedestre traumatizado em colis�o com um ve�culo a pedal'},;
						{'V02','Pedestre traumatizado em colis�o com um ve�culo a motor de duas ou tr�s rodas'},;
						{'V03','Pedestre traumatizado em colis�o com um autom�vel [carro], "pick up" ou caminhonete'},;
						{'V04','Pedestre traumatizado em colis�o com um ve�culo de transporte pesado ou com um �nibus'},;
						{'V05','Pedestre traumatizado em colis�o com trem [comboio] ou um ve�culo ferrovi�rio'},;
						{'V06','Pedestre traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V09','Pedestre traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V10','Ciclista traumatizado em colis�o com um pedestre ou um animal'},;
						{'V11','Ciclista traumatizado em colis�o com outro ve�culo a pedal'},;
						{'V12','Ciclista traumatizado em colis�o com um ve�culo a motor de duas ou tr�s rodas'},;
						{'V13','Ciclista traumatizado em colis�o com um autom�vel, "pick up" ou caminhonete'},;
						{'V14','Ciclista traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V15','Ciclista traumatizado em colis�o com um trem ou um ve�culo ferrovi�rio'},;
						{'V16','Ciclista traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V17','Ciclista traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V18','Ciclista traumatizado em um acidente de transporte sem colis�o'},;
						{'V19','Ciclista traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V20','Motociclista traumatizado em colis�o com um pedestre ou um animal'},;
						{'V21','Motociclista traumatizado em colis�o com um ve�culo a pedal'},;
						{'V22','Motociclista traumatizado em colis�o com um ve�culo a motor de duas ou tr�s rodas'},;
						{'V23','Motociclista traumatizado em colis�o com um autom�vel [carro], "pick up" ou caminhonete'},;
						{'V24','Motociclista traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V25','Motociclista traumatizado em colis�o com um trem ou um ve�culo ferrovi�rio'},;
						{'V26','Motociclista traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V27','Motociclista traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V28','Motociclista traumatizado em um acidente de transporte sem colis�o'},;
						{'V29','Motociclista traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V30','Ocupante de um triciclo motorizado traumatizado em colis�o com um pedestre ou um animal'},;
						{'V31','Ocupante de um triciclo motorizado traumatizado em colis�o com um ve�culo a pedal'},;
						{'V32','Ocupante de um triciclo motorizado traumatizado em colis�o com outro ve�culo a motor de duas ou tr�s rodas'},;
						{'V33','Ocupante de um triciclo motorizado traumatizado em colis�o com um autom�vel, "pick up" ou caminhonete'},;
						{'V34','Ocupante de um triciclo motorizado traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V35','Ocupante de um triciclo motorizado traumatizado em colis�o com um trem [comboio] ou um ve�culo ferrovi�rio'},;
						{'V36','Ocupante de um triciclo motorizado traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V37','Ocupante de um triciclo motorizado traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V38','Ocupante de um triciclo motorizado traumatizado em um acidente de transporte sem colis�o'},;
						{'V39','Ocupante de um triciclo motorizado traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V40','Ocupante de um autom�vel [carro] traumatizado em colis�o com um pedestre ou um animal'},;
						{'V41','Ocupante de um autom�vel [carro] traumatizado em colis�o com um ve�culo a pedal'},;
						{'V42','Ocupante de um autom�vel [carro] traumatizado em colis�o com outro ve�culo a motor de duas ou tr�s rodas'},;
						{'V43','Ocupante de um autom�vel [carro] traumatizado em colis�o com um autom�vel [carro], "pick up" ou caminhonete'},;
						{'V44','Ocupante de um autom�vel [carro] traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V45','Ocupante de um autom�vel [carro] traumatizado em colis�o com um trem [comboio] ou um ve�culo ferrovi�rio'},;
						{'V46','Ocupante de um autom�vel [carro] traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V47','Ocupante de um autom�vel [carro] traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V48','Ocupante de um autom�vel [carro] traumatizado em um acidente de transporte sem colis�o'},;
						{'V49','Ocupante de um autom�vel [carro] traumatizado em outro acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V50','Ocupante de uma caminhonete traumatizado em colis�o com um pedestre ou um animal'},;
						{'V51','Ocupante de uma caminhonete traumatizado em colis�o com um ve�culo a pedal'},;
						{'V52','Ocupante de uma caminhonete traumatizado em colis�o com ve�culo a motor de duas ou tr�s rodas'},;
						{'V53','Ocupante de uma caminhonete traumatizado em colis�o com um autom�vel [carro] ou uma caminhonete'},;
						{'V54','Ocupante de uma caminhonete traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V55','Ocupante de uma caminhonete traumatizado em colis�o com um trem [comboio] ou ve�culo ferrovi�rio'},;
						{'V56','Ocupante de uma caminhonete traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V57','Ocupante de uma caminhonete traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V58','Ocupante de uma caminhonete traumatizado em um acidente de transporte sem colis�o'},;
						{'V59','Ocupante de uma caminhonete traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V60','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um pedestre ou um animal'},;
						{'V61','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um ve�culo a pedal'},;
						{'V62','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um ve�culo a motor de duas ou tr�s rodas'},;
						{'V63','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um autom�vel [carro] ou uma caminhonete'},;
						{'V64','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um outro ve�culo de transporte pesado ou um �nibus'},;
						{'V65','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um trem [comboio] ou um ve�culo ferrovi�rio'},;
						{'V66','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um outro ve�culo n�o-motorizado'},;
						{'V67','Ocupante de um ve�culo de transporte pesado traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V68','Ocupante de um ve�culo de transporte pesado traumatizado em um acidente de transporte sem colis�o'},;
						{'V69','Ocupante de um ve�culo de transporte pesado traumatizado em outros acidentes de transporte n�o especificados'},;
						{'V70','Ocupante de um �nibus traumatizado em colis�o com um pedestre ou um animal'},;
						{'V71','Ocupante de um �nibus traumatizado em colis�o com um ve�culo a pedal'},;
						{'V72','Ocupante de um �nibus traumatizado em colis�o com um outro ve�culo a motor de duas ou tr�s rodas'},;
						{'V73','Ocupante de um �nibus traumatizado em colis�o com um autom�vel [carro] ou uma caminhonete'},;
						{'V74','Ocupante de um �nibus traumatizado em colis�o com um ve�culo de transporte pesado ou um �nibus'},;
						{'V75','Ocupante de um �nibus traumatizado em colis�o com um trem [comboio] ou um ve�culo ferrovi�rio'},;
						{'V76','Ocupante de um �nibus traumatizado em colis�o com outro ve�culo n�o-motorizado'},;
						{'V77','Ocupante de um �nibus traumatizado em colis�o com um objeto fixo ou parado'},;
						{'V78','Ocupante de um �nibus traumatizado em um acidente de transporte sem colis�o'},;
						{'V79','Ocupante de um �nibus traumatizado em outros acidentes de transporte e em acidentes de transporte n�o especificados'},;
						{'V80','Pessoa montada em animal ou ocupante de um ve�culo a tra��o animal traumatizado em um acidente de transporte'},;
						{'V81','Ocupante de um trem [comboio] ou um ve�culo ferrovi�rio traumatizado em um acidente de transporte'},;
						{'V82','Ocupante de um bonde [carro el�trico] traumatizado em um acidente de transporte'},;
						{'V83','Ocupante de um ve�culo especial a motor usado principalmente em �reas industriais traumatizado em um acidente de transporte'},;
						{'V84','Ocupante de um ve�culo especial a motor de uso essencialmente agr�cola traumatizado em um acidente de transporte'},;
						{'V85','Ocupante de um ve�culo a motor especial de constru��es traumatizado em um acidente de transporte'},;
						{'V86','Ocupante de um ve�culo especial para qualquer terreno ou de outro ve�culo a motor projetado essencialmente para uso n�o em via p�blica, traumatizado em um acidente de transporte'},;
						{'V87','Acidente de tr�nsito de tipo especificado, mas sendo desconhecido o modo de transporte da v�tima'},;
						{'V88','Acidente n�o-de-tr�nsito de tipo especificado, mas sendo desconhecido o modo de transporte da v�tima'},;
						{'V89','Acidente com um ve�culo a motor ou n�o-motorizado, tipo(s) de ve�culo(s) n�o especificado(s)'},;
						{'V90','Acidente com embarca��o causando afogamento e submers�o'},;
						{'V91','Acidente com embarca��o causando outro tipo de traumatismo'},;
						{'V92','Afogamento e submers�o relacionados com transporte por �gua sem acidente com a embarca��o'},;
						{'V93','Acidente a bordo de uma embarca��o, sem acidente da embarca��o e n�o causando afogamento ou submers�o'},;
						{'V94','Outros acidentes de transporte por �gua e os n�o especificados'},;
						{'V95','Acidente de aeronave a motor causando traumatismo ao ocupante'},;
						{'V96','Acidente de uma aeronave sem motor causando traumatismo a ocupante'},;
						{'V97','Outros acidentes especificados de transporte a�reo'},;
						{'V98','Outros acidentes de transporte especificados'},;
						{'V99','Acidente de transporte n�o especificado'},;
						{'W00','Queda no mesmo n�vel envolvendo gelo e neve'},;
						{'W01','Queda no mesmo n�vel por escorreg�o, trope��o ou passos em falsos [trasp�s]'},;
						{'W02','Queda envolvendo patins de rodas ou para gelo, esqui ou pranchas de rodas'},;
						{'W03','Outras quedas no mesmo n�vel por colis�o com ou empurr�o por outra pessoa'},;
						{'W04','Queda, enquanto estava sendo carregado ou apoiado por outra(s) pessoa(s)'},;
						{'W05','Queda envolvendo uma cadeira de rodas'},;
						{'W06','Queda de um leito'},;
						{'W07','Queda de uma cadeira'},;
						{'W08','Queda de outro tipo de mob�lia'},;
						{'W09','Queda envolvendo equipamento de "playground"'},;
						{'W10','Queda em ou de escadas ou degraus'},;
						{'W11','Queda em ou de escadas de m�o'},;
						{'W12','Queda em ou de um andaime'},;
						{'W13','Queda de ou para fora de edif�cios ou outras estruturas'},;
						{'W14','Queda de �rvore'},;
						{'W15','Queda de penhasco'},;
						{'W16','Mergulho ou pulo na �gua causando outro traumatismo que n�o afogamento ou submers�o'},;
						{'W17','Outras quedas de um n�vel a outro'},;
						{'W18','Outras quedas no mesmo n�vel'},;
						{'W19','Queda sem especifica��o'},;
						{'W20','Impacto causado por objeto lan�ado, projetado ou em queda'},;
						{'W21','Impacto acidental ativo ou passivo causado por equipamento esportivo'},;
						{'W22','Impacto acidental ativo ou passivo causado por outros objetos'},;
						{'W23','Apertado, colhido, comprimido ou esmagado dentro de ou entre objetos'},;
						{'W24','Contato com elevadores e instrumentos de transmiss�o, n�o classificados em outra parte'},;
						{'W25','Contato com vidro cortante'},;
						{'W26','Contato com faca, espada e punhal'},;
						{'W27','Contato com ferramentas manuais sem motor'},;
						{'W28','Contato com segadeira motorizada para cortar ou aparar a grama'},;
						{'W29','Contato com outros utens�lios manuais e aparelhos dom�sticos equipados com motor'},;
						{'W30','Contato com maquinaria agr�cola'},;
						{'W31','Contato com outras m�quinas e com as n�o especificadas'},;
						{'W32','Proj�til de rev�lver'},;
						{'W33','Rifle, espingarda e armas de fogo de maior tamanho'},;
						{'W34','Proj�teis de outras armas de fogo e das n�o especificadas'},;
						{'W35','Explos�o ou ruptura de caldeira'},;
						{'W36','Explos�o ou ruptura de cilindro de g�s'},;
						{'W37','Explos�o ou ruptura de pneum�tico, tubula��o ou mangueira, pressurizados'},;
						{'W38','Explos�o ou ruptura de outros aparelhos pressurizados especificados'},;
						{'W39','Queima de fogos de artif�cio'},;
						{'W40','Explos�o de outros materiais'},;
						{'W41','Exposi��o a um jato de alta press�o'},;
						{'W42','Exposi��o ao ru�do'},;
						{'W43','Exposi��o � vibra��o'},;
						{'W44','Penetra��o de corpo estranho no ou atrav�s de olho ou orif�cio natural'},;
						{'W45','Penetra��o de corpo ou objeto estranho atrav�s da pele'},;
						{'W46','Contato com agulha hipod�rmica'},;
						{'W49','Exposi��o a outras for�as mec�nicas inanimadas e �s n�o especificadas'},;
						{'W50','Golpe, pancada, pontap�, mordedura ou escoria��o infligidos por outra pessoa'},;
						{'W51','Colis�o entre duas pessoas'},;
						{'W52','Esmagado, empurrado ou pisoteado por multid�o ou debandada em massa de pessoas'},;
						{'W53','Mordedura de rato'},;
						{'W54','Mordedura ou golpe provocado por c�o'},;
						{'W55','Mordedura ou golpe provocado por outros animais mam�feros'},;
						{'W56','Contato com animais marinhos'},;
						{'W57','Mordeduras e picadas de inseto e de outros artr�podes, n�o-venenosos'},;
						{'W58','Mordedura ou golpe provocado por crocodilo ou alig�tor'},;
						{'W59','Mordedura ou esmagamento provocado por outros r�pteis'},;
						{'W60','Contato com espinhos de plantas ou com folhas agu�adas'},;
						{'W64','Exposi��o a outras for�as mec�nicas animadas e �s n�o especificadas'},;
						{'W65','Afogamento e submers�o durante banho em banheira'},;
						{'W66','Afogamento e submers�o consecutiva a queda dentro de uma banheira'},;
						{'W67','Afogamento e submers�o em piscina'},;
						{'W68','Afogamento e submers�o conseq�ente a queda dentro de uma piscina'},;
						{'W69','Afogamento e submers�o em �guas naturais'},;
						{'W70','Afogamento e submers�o conseq�entes a queda dentro de �guas naturais'},;
						{'W73','Outros afogamentos e submers�o especificados'},;
						{'W74','Afogamento e submers�o n�o especificados'},;
						{'W75','Sufoca��o e estrangulamento acidental na cama'},;
						{'W76','Outro enforcamento e estrangulamento acidental'},;
						{'W77','Risco a respira��o devido a desmoronamento, queda de terra e de outras subst�ncias'},;
						{'W78','Inala��o do conte�do g�strico'},;
						{'W79','Inala��o e ingest�o de alimentos causando obstru��o do trato respirat�rio'},;
						{'W80','Inala��o e ingest�o de outros objetos causando obstru��o do trato respirat�rio'},;
						{'W81','Confinado ou aprisionado em um ambiente pobre em oxig�nio'},;
						{'W83','Outros riscos especificados � respira��o'},;
						{'W84','Riscos n�o especificados � respira��o'},;
						{'W85','Exposi��o a linhas de transmiss�o de corrente el�trica'},;
						{'W86','Exposi��o a outra corrente el�trica especificada'},;
						{'W87','Exposi��o a corrente el�trica n�o especificada'},;
						{'W88','Exposi��o a radia��o ionizante'},;
						{'W89','Exposi��o a fontes luminosas artificiais vis�veis ou � luz ultravioleta'},;
						{'W90','Exposi��o a outros tipos de radia��o n�o-ionizante'},;
						{'W91','Exposi��o a tipo n�o especificado de radia��o'},;
						{'W92','Exposi��o a um calor excessivo de origem artificial'},;
						{'W93','Exposi��o a um frio excessivo de origem artificial'},;
						{'W94','Exposi��o a alta, baixa e a varia��es da press�o atmosf�rica'},;
						{'W99','Exposi��o a outros fatores ambientais artificiais e aos n�o especificados'},;
						{'X00','Exposi��o a fogo n�o-controlado em um edif�cio ou outro tipo de constru��o'},;
						{'X01','Exposi��o a fogo n�o-controlado fora de um edif�cio ou de outro tipo de constru��o'},;
						{'X02','Exposi��o a fogo controlado em um edif�cio ou outro tipo de constru��o'},;
						{'X03','Exposi��o a fogo controlado fora de um edif�cio ou de outro tipo de constru��o'},;
						{'X04','Exposi��o a combust�o de subst�ncia muito inflam�vel'},;
						{'X05','Exposi��o a combust�o de roupa de dormir'},;
						{'X06','Exposi��o a combust�o de outro tipo de roupa ou de acess�rios'},;
						{'X08','Exposi��o a outro tipo especificado de fuma�a, fogo ou chamas'},;
						{'X09','Exposi��o a tipo n�o especificado de fuma�a, fogo ou chamas'},;
						{'X10','Contato com bebidas, alimentos, gordura e �leo de cozinha quentes'},;
						{'X11','Contato com �gua corrente quente de torneira'},;
						{'X12','Contato com outros l�quidos quentes'},;
						{'X13',"Contato com vapor d'�gua e com vapores quentes"},;
						{'X14','Contato com ar e gases quentes'},;
						{'X15','Contato com aparelhos dom�sticos quentes'},;
						{'X16','Contato com aquecedores, radiadores e tubula��o'},;
						{'X17','Contato com motores, m�quinas e ferramentas quentes'},;
						{'X18','Contato com outros metais quentes'},;
						{'X19','Contato com outras fontes de calor ou com subst�ncias quentes n�o especificados'},;
						{'X20','Contato com serpentes e lagartos venenosos'},;
						{'X21','Contato com aranhas venenosas'},;
						{'X22','Contato com escorpi�es'},;
						{'X23','Contato com abelhas, vespas e vesp�es'},;
						{'X24','Contato com centop�ias e miri�podes venenosas (tropicais)'},;
						{'X25','Contato com outros artr�podes venenosos'},;
						{'X26','Contato com animais e plantas marinhos venenosos'},;
						{'X27','Contato com outros animais venenosos especificados'},;
						{'X28','Contato com outras plantas venenosas especificadas'},;
						{'X29','Contato com animais ou plantas venenosos, sem especifica��o'},;
						{'X30','Exposi��o a calor natural excessivo'},;
						{'X31','Exposi��o a frio natural excessivo'},;
						{'X32','Exposi��o � luz solar'},;
						{'X33','V�tima de raio'},;
						{'X34','V�tima de terremoto'},;
						{'X35','V�tima de erup��o vulc�nica'},;
						{'X36','V�tima de avalanche, desabamento de terra e outros movimentos da superf�cie terrestre'},;
						{'X37','V�tima de tempestade catacl�smica'},;
						{'X38','V�tima de inunda��o'},;
						{'X39','Exposi��o a outras for�as da natureza e �s n�o especificadas'},;
						{'X40','Envenenamento [intoxica��o] acidental por e exposi��o a analg�sicos, antipir�ticos e anti-reum�ticos, n�o-opi�ceos'},;
						{'X41','Envenenamento [intoxica��o] acidental por e exposi��o a anticonvulsivantes [antiepil�pticos], sedativos, hipn�ticos, antiparkinsonianos e psicotr�picos n�o classificadas em outra parte'},;
						{'X42','Envenenamento [intoxica��o] acidental por e exposi��o a narc�ticos e psicodisl�pticos [alucin�genos] n�o classificados em outra parte'},;
						{'X43','Envenenamento [intoxica��o] acidental por e exposi��o a outras subst�ncias farmacol�gicas de a��o sobre o sistema nervoso aut�nomo'},;
						{'X44','Envenenamento [intoxica��o] acidental por e exposi��o a outras drogas, medicamentos e subst�ncias biol�gicas n�o especificadas'},;
						{'X45','Envenenamento [intoxica��o] acidental por e exposi��o ao �lcool'},;
						{'X46','Envenenamento [intoxica��o] acidental por e exposi��o a solventes org�nicos e hidrocarbonetos halogenados e seus vapores'},;
						{'X47','Intoxica��o acidental por e exposi��o a outros gases e vapores'},;
						{'X48','Envenenamento [intoxica��o] acidental por e exposi��o a pesticidas'},;
						{'X49','Envenenamento [intoxica��o] acidental por e exposi��o a outras subst�ncias qu�micas nocivas e �s n�o especificadas'},;
						{'X50','Excesso de exerc�cios e movimentos vigorosos ou repetitivos'},;
						{'X51','Viagem e movimento'},;
						{'X52','Estadia prolongada em ambiente agravitacional'},;
						{'X53','Falta de alimento'},;
						{'X54','Falta de �gua'},;
						{'X57','Priva��o n�o especificada'},;
						{'X58','Exposi��o a outros fatores especificados'},;
						{'X59','Exposi��o a fatores n�o especificados'},;
						{'X60','Auto-intoxica��o por e exposi��o, intencional, a analg�sicos, antipir�ticos e anti-reum�ticos, n�o-opi�ceos'},;
						{'X61','Auto-intoxica��o por e exposi��o, intencional, a drogas anticonvulsivantes [antiepil�pticos] sedativos, hipn�ticos, antiparkinsonianos e psicotr�picos n�o classificados em outra parte'},;
						{'X62','Auto-intoxica��o por e exposi��o, intencional, a narc�ticos e psicodisl�pticos [alucin�genos] n�o classificados em outra parte'},;
						{'X63','Auto-intoxica��o por e exposi��o, intencional, a outras subst�ncias farmacol�gicas de a��o sobre o sistema nervoso aut�nomo'},;
						{'X64','Auto-intoxica��o por e exposi��o, intencional, a outras drogas, medicamentos e subst�ncias biol�gicas e �s n�o especificadas'},;
						{'X65','Auto-intoxica��o volunt�ria por �lcool'},;
						{'X66','Auto-intoxica��o intencional por solventes org�nicos, hidrocarbonetos halogenados e seus vapores'},;
						{'X67','Auto-intoxica��o intencional por outros gases e vapores'},;
						{'X68','Auto-intoxica��o por e exposi��o, intencional, a pesticidas'},;
						{'X69','Auto-intoxica��o por e exposi��o, intencional, a outros produtos qu�micos e subst�ncias nocivas n�o especificadas'},;
						{'X70','Les�o autoprovocada intencionalmente por enforcamento, estrangulamento e sufoca��o'},;
						{'X71','Les�o autoprovocada intencionalmente por afogamento e submers�o'},;
						{'X72','Les�o autoprovocada intencionalmente por disparo de arma de fogo de m�o'},;
						{'X73','Les�o autoprovocada intencionalmente por disparo de espingarda, carabina, ou arma de fogo de maior calibre'},;
						{'X74','Les�o autoprovocada intencionalmente por disparo de outra arma de fogo e de arma de fogo n�o especificada'},;
						{'X75','Les�o autoprovocada intencionalmente por dispositivos explosivos'},;
						{'X76','Les�o autoprovocada intencionalmente pela fuma�a, pelo fogo e por chamas'},;
						{'X77','Les�o autoprovocada intencionalmente por vapor de �gua, gases ou objetos quentes'},;
						{'X78','Les�o autoprovocada intencionalmente por objeto cortante ou penetrante'},;
						{'X79','Les�o autoprovocada intencionalmente por objeto contundente'},;
						{'X80','Les�o autoprovocada intencionalmente por precipita��o de um lugar elevado'},;
						{'X81','Les�o autoprovocada intencionalmente por precipita��o ou perman�ncia diante de um objeto em movimento'},;
						{'X82','Les�o autoprovocada intencionalmente por impacto de um ve�culo a motor'},;
						{'X83','Les�o autoprovocada intencionalmente por outros meios especificados'},;
						{'X84','Les�o autoprovocada intencionalmente por meios n�o especificados'},;
						{'X85','Agress�o por meio de drogas, medicamentos e subst�ncias biol�gicas'},;
						{'X86','Agress�o por meio de subst�ncias corrosivas'},;
						{'X87','Agress�o por pesticidas'},;
						{'X88','Agress�o por meio de gases e vapores'},;
						{'X89','Agress�o por meio de outros produtos qu�micos e subst�ncias nocivas especificados'},;
						{'X90','Agress�o por meio de produtos qu�micos e subst�ncias nocivas n�o especificados'},;
						{'X91','Agress�o por meio de enforcamento, estrangulamento e sufoca��o'},;
						{'X92','Agress�o por meio de afogamento e submers�o'},;
						{'X93','Agress�o por meio de disparo de arma de fogo de m�o'},;
						{'X94','Agress�o por meio de disparo de espingarda, carabina ou arma de fogo de maior calibre'},;
						{'X95','Agress�o por meio de disparo de outra arma de fogo ou de arma n�o especificada'},;
						{'X96','Agress�o por meio de material explosivo'},;
						{'X97','Agress�o por meio de fuma�a, fogo e chamas'},;
						{'X98','Agress�o por meio de vapor de �gua, gases ou objetos quentes'},;
						{'X99','Agress�o por meio de objeto cortante ou penetrante'},;
						{'Y00','Agress�o por meio de um objeto contundente'},;
						{'Y01','Agress�o por meio de proje��o de um lugar elevado'},;
						{'Y02','Agress�o por meio de proje��o ou coloca��o da v�tima diante de um objeto em movimento'},;
						{'Y03','Agress�o por meio de impacto de um ve�culo a motor'},;
						{'Y04','Agress�o por meio de for�a corporal'},;
						{'Y05','Agress�o sexual por meio de for�a f�sica'},;
						{'Y06','Neglig�ncia e abandono'},;
						{'Y07','Outras s�ndromes de maus tratos'},;
						{'Y08','Agress�o por outros meios especificados'},;
						{'Y09','Agress�o por meios n�o especificados'},;
						{'Y10','Envenenamento [intoxica��o] por e exposi��o a analg�sicos, antipir�ticos e anti-reum�ticos n�o-opi�ceos, inten��o n�o determinada'},;
						{'Y11','Envenenamento [intoxica��o] por e exposi��o a anticonvulsivantes [antiepil�pticos], sedativos, hipn�ticos, antiparkinsonianos e psicotr�picos n�o classificados em outra parte, inten��o n�o determinada'},;
						{'Y12','Envenenamento [intoxica��o] por e exposi��o a narc�ticos e a psicodisl�pticos [alucin�genos] n�o classificados em outra parte, inten��o n�o determinada'},;
						{'Y13','Envenenamento [intoxica��o] por e exposi��o a outras subst�ncias farmacol�gicas de a��o sobre o sistema nervoso aut�nomo, inten��o n�o determinada'},;
						{'Y14','Envenenamento [intoxica��o] por e exposi��o a outras drogas, medicamentos e subst�ncias biol�gicas e as n�o especificadas, inten��o n�o determinada'},;
						{'Y15','Envenenamento [intoxica��o] por e exposi��o ao �lcool, inten��o n�o determinada'},;
						{'Y16','Envenenamento [intoxica��o] por e exposi��o a solventes org�nicos e hidrocarbonetos halogenados e seus vapores, inten��o n�o determinada'},;
						{'Y17','Envenenamento [intoxica��o] por e exposi��o a outros gases e vapores, inten��o n�o determinada'},;
						{'Y18','Envenenamento [intoxica��o] por e exposi��o a pesticidas, inten��o n�o determinada'},;
						{'Y19','Envenenamento [intoxica��o] por e exposi��o a outros produtos qu�micos e subst�ncias nocivas e aos n�o especificados, inten��o n�o determinada'},;
						{'Y20','Enforcamento, estrangulamento e sufoca��o, inten��o n�o determinada'},;
						{'Y21','Afogamento e submers�o, inten��o n�o determinada'},;
						{'Y22','Disparo de pistola, inten��o n�o determinada'},;
						{'Y23','Disparo de fuzil, carabina e arma de fogo de maior calibre, inten��o n�o determinada'},;
						{'Y24','Disparo de outra arma de fogo e de arma de fogo n�o especificada, inten��o n�o determinada'},;
						{'Y25','Contato com material explosivo, inten��o n�o determinada'},;
						{'Y26','Exposi��o a fuma�a, fogo e chamas, inten��o n�o determinada'},;
						{'Y27','Exposi��o a vapor de �gua, gases ou objetos quentes, inten��o n�o determinada'},;
						{'Y28','Contato com objeto cortante ou penetrante, inten��o n�o determinada'},;
						{'Y29','Contato com objeto contundente, inten��o n�o determinada'},;
						{'Y30','Queda, salto ou empurrado de um lugar elevado, inten��o n�o determinada'},;
						{'Y31','Queda, perman�ncia ou corrida diante de um objeto em movimento, inten��o n�o determinada'},;
						{'Y32','Impacto de um ve�culo a motor, inten��o n�o determinada'},;
						{'Y33','Outros fatos ou eventos especificados, inten��o n�o determinada'},;
						{'Y34','Fatos ou eventos n�o especificados e inten��o n�o determinada'},;
						{'Y35','Interven��o legal'},;
						{'Y36','Opera��es de guerra'},;
						{'Y40','Efeitos adversos de antibi�ticos sist�micos'},;
						{'Y41','Efeitos adversos de outros antiinfecciosos e antiparasit�rios sist�micos'},;
						{'Y42','Efeitos adversos de horm�nios e seus substitutos sint�ticos e antagonistas, n�o classificados em outra parte'},;
						{'Y43','Efeitos adversos de subst�ncias de a��o primariamente sist�mica'},;
						{'Y44','Efeitos adversos de subst�ncias farmacol�gicas que atuam primariamente sobre os constituintes do sangue'},;
						{'Y45','Efeitos adversos de subst�ncias analg�sicas, antipir�ticas e antiinflamat�rias'},;
						{'Y46','Efeitos adversos de drogas anticonvulsivantes (antiepil�pticas) e antiparkinsonianas'},;
						{'Y47','Efeitos adversos de sedativos, hipn�ticos e tranquilizantes [ansiol�ticos]'},;
						{'Y48','Efeitos adversos de anest�sicos e gases terap�uticos'},;
						{'Y49','Efeitos adversos de subst�ncias psicotr�picas, n�o classificadas em outra parte'},;
						{'Y50','Efeitos adversos de estimulantes do sistema nervoso central, n�o classificados em outra parte'},;
						{'Y51','Efeitos adversos de drogas que atuam primariamente sobre o sistema nervoso aut�nomo'},;
						{'Y52','Efeitos adversos de subst�ncias que atuam primariamente sobre o aparelho cardiovascular'},;
						{'Y53','Efeitos adversos de subst�ncias que atuam primariamente sobre o aparelho gastrointestinal'},;
						{'Y54','Efeitos adversos de subst�ncias que atuam primariamente sobre o metabolismo da �gua, dos sais minerais e do �cido �rico'},;
						{'Y55','Efeitos adversos de subst�ncias que atuam primariamente sobre os m�sculos lisos e esquel�ticos e sobre o aparelho respirat�rio'},;
						{'Y56','Efeitos adversos de subst�ncias de uso t�pico que atuam primariamente sobre a pele e as membranas mucosas e drogas de uso oftalmol�gico, otorrinolaringol�gico e dent�rio'},;
						{'Y57','Efeitos adversos de outras drogas e medicamentos e as n�o especificadas'},;
						{'Y58','Efeitos adversos de vacinas bacterianas'},;
						{'Y59','Efeitos adversos de outras vacinas e subst�ncias biol�gicas e as n�o especificadas'},;
						{'Y60','Corte, pun��o, perfura��o ou hemorragia acidentais durante a presta��o de cuidados m�dicos ou cir�rgicos'},;
						{'Y61','Objeto estranho deixado acidentalmente no corpo durante a presta��o de cuidados cir�rgicos e m�dicos'},;
						{'Y62','Assepsia insuficiente durante a presta��o de cuidados cir�rgicos e m�dicos'},;
						{'Y63','Erros de dosagem durante a presta��o de cuidados m�dicos e cir�rgicos'},;
						{'Y64','Medicamentos ou subst�ncias biol�gicas contaminados'},;
						{'Y65','Outros acidentes durante a presta��o de cuidados m�dicos e cir�rgicos'},;
						{'Y66','N�o administra��o de cuidado m�dico e cir�rgico'},;
						{'Y69','Acidente n�o especificado durante a presta��o de cuidado m�dico e cir�rgico'},;
						{'Y70','Dispositivos (aparelhos) de anestesiologia, associados a incidentes adversos'},;
						{'Y71','Dispositivos (aparelhos) cardiovasculares, associados a incidentes adversos'},;
						{'Y72','Dispositivos (aparelhos) utilizados em otorrinolaringologia, associados a incidentes adversos'},;
						{'Y73','Dispositivos (aparelhos) usados em gastroenterologia e em urologia, associados a incidentes adversos'},;
						{'Y74','Dispositivos (aparelhos) gerais de uso hospitalar ou pessoal, associados a incidentes adversos'},;
						{'Y75','Dispositivos (aparelhos) utilizados em neurologia, associados a incidentes adversos'},;
						{'Y76','Dispositivos (aparelhos) utilizados em obstetr�cia e em ginecologia, associados a incidentes adversos'},;
						{'Y77','Dispositivos (aparelhos) utilizados em oftalmologia, associados a incidentes adversos'},;
						{'Y78','Dispositivos (aparelhos) utilizados em radiologia, associados a incidentes adversos'},;
						{'Y79','Dispositivos (aparelhos) ortop�dicos, associado a incidentes adversos'},;
						{'Y80','Dispositivos (aparelhos) utilizados em medicina f�sica (fisiatria), associado a incidentes adversos'},;
						{'Y81','Dispositivos (aparelhos) utilizados em cirurgia geral ou cirurgia pl�stica, associados a incidente adversos'},;
						{'Y82','Outros dispositivos (aparelhos) associados a incidentes adversos e os n�o especificados'},;
						{'Y83','Rea��o anormal em paciente ou complica��o tardia, causadas por interven��o cir�rgica e por outros atos cir�rgicos, sem men��o de acidente durante a interven��o'},;
						{'Y84','Rea��o anormal em paciente ou complica��o tardia, causadas por outros procedimentos m�dicos, sem men��o de acidente durante o procedimento'},;
						{'Y85','Seq�elas de acidentes de transporte'},;
						{'Y86','Seq�elas de outros acidentes'},;
						{'Y87','Seq�elas de uma les�o autoprovocada intencionalmente, de agress�o ou de um fato cuja inten��o � indeterminada'},;
						{'Y88','Seq�elas de cuidado m�dico ou cir�rgico considerados como uma causa externa'},;
						{'Y89','Seq�elas de outras causas externas'},;
						{'Y90','Evid�ncia de alcoolismo determinada por taxas de alcoolemia'},;
						{'Y91','Evid�ncia de alcoolismo determinada pelo n�vel da intoxica��o'},;
						{'Y95','Circunst�ncia relativa as condi��es nosocomiais (hospitalares)'},;
						{'Y96','Circunst�ncia relativa �s condi��es de trabalho'},;
						{'Y97','Circunst�ncias relativas a condi��es de polui��o ambiental'},;
						{'Y98','Circunst�ncias relativas a condi��es do modo de vida'},;
						{'Z00','Exame geral e investiga��o de pessoas sem queixas ou diagn�stico relatado'},;
						{'Z01','Outros exames e investiga��es especiais de pessoas sem queixa ou diagn�stico relatado'},;
						{'Z02','Exame m�dico e consulta com finalidades administrativas'},;
						{'Z03','Observa��o e avalia��o m�dica por doen�as e afec��es suspeitas'},;
						{'Z04','Exame e observa��o por outras raz�es'},;
						{'Z08','Exame de seguimento ap�s tratamento por neoplasia maligna'},;
						{'Z09','Exame de seguimento ap�s tratamento de outras afec��es que n�o neoplasias malignas'},;
						{'Z10','Exame geral de rotina ("check up") de uma subpopula��o definida'},;
						{'Z11','Exame especial de rastreamento ("screening") de doen�as infecciosas e parasit�rias'},;
						{'Z12','Exame especial de rastreamento ("screening") de neoplasias'},;
						{'Z13','Exame especial de rastreamento ("screening") de outros transtornos e doen�as'},;
						{'Z20','Contato com e exposi��o a doen�as transmiss�veis'},;
						{'Z21','Estado de infec��o assintom�tica pelo v�rus da imunodefici�ncia humana [HIV]'},;
						{'Z22','Portador de doen�a infecciosa'},;
						{'Z23','Necessidade de imuniza��o contra uma �nica doen�a bacteriana'},;
						{'Z24','Necessidade de imuniza��o contra algumas doen�as virais �nicas'},;
						{'Z25','Necessidade de imuniza��o contra outras doen�as virais �nicas'},;
						{'Z26','Necessidade de imuniza��o contra outras doen�as infecciosas �nicas'},;
						{'Z27','Necessidade de imuniza��o associada contra combina��es de doen�as infecciosas'},;
						{'Z28','Imuniza��o n�o realizada'},;
						{'Z29','Necessidade de outras medidas profil�ticas'},;
						{'Z30','Anticoncep��o'},;
						{'Z31','Medidas de procria��o'},;
						{'Z32','Exame ou teste de gravidez'},;
						{'Z33','Gravidez como achado casual'},;
						{'Z34','Supervis�o de gravidez normal'},;
						{'Z35','Supervis�o de gravidez de alto risco'},;
						{'Z36','Rastreamento ("screening") pr�-natal'},;
						{'Z37','Resultado do parto'},;
						{'Z38','Nascidos vivos [nado-vivos] segundo o local de nascimento'},;
						{'Z39','Assist�ncia e exame p�s-natal'},;
						{'Z40','Cirurgia profil�tica'},;
						{'Z41','Procedimentos para outros prop�sitos exceto cuidados de sa�de'},;
						{'Z42','Seguimento envolvendo cirurgia pl�stica'},;
						{'Z43','Aten��o a orif�cios artificiais'},;
						{'Z44','Coloca��o e ajustamento de aparelhos de pr�tese externa'},;
						{'Z45','Ajustamento e manuseio de dispositivo implantado'},;
						{'Z46','Coloca��o e ajustamento de outros aparelhos'},;
						{'Z47','Outros cuidados de seguimento ortop�dico'},;
						{'Z48','Outro seguimento cir�rgico'},;
						{'Z49','Cuidados envolvendo di�lise'},;
						{'Z50','Cuidados envolvendo o uso de procedimentos de reabilita��o'},;
						{'Z51','Outros cuidados m�dicos'},;
						{'Z52','Doadores de �rg�os e tecidos'},;
						{'Z53','Pessoas em contato com servi�os de sa�de para procedimentos espec�ficos n�o realizados'},;
						{'Z54','Convalescen�a'},;
						{'Z55','Problemas relacionados com a educa��o e com a alfabetiza��o'},;
						{'Z56','Problemas relacionados com o emprego e com o desemprego'},;
						{'Z57','Exposi��o ocupacional a fatores de risco'},;
						{'Z58','Problemas relacionados com o ambiente f�sico'},;
						{'Z59','Problemas relacionados com a habita��o e com as condi��es econ�micas'},;
						{'Z60','Problemas relacionados com o meio social'},;
						{'Z61','Problemas relacionados com eventos negativos de vida na inf�ncia'},;
						{'Z62','Outros problemas relacionados com a educa��o da crian�a'},;
						{'Z63','Outros problemas relacionados com o grupo prim�rio de apoio, inclusive com a situa��o familiar'},;
						{'Z64','Problemas relacionados com algumas outras circunst�ncias psicossociais'},;
						{'Z65','Problemas relacionados com outras circunst�ncias psicossociais'},;
						{'Z70','Aconselhamento relativo �s atitudes, comportamento e orienta��o em mat�ria de sexualidade'},;
						{'Z71','Pessoas em contato com os servi�os de sa�de para outros aconselhamentos e conselho m�dico, n�o classificados em outra parte'},;
						{'Z72','Problemas relacionados com o estilo de vida'},;
						{'Z73','Problemas relacionados com a organiza��o de seu modo de vida'},;
						{'Z74','Problemas relacionados com a depend�ncia de uma pessoa que oferece cuidados de sa�de'},;
						{'Z75','Problemas relacionados com as facilidades m�dicas e outros cuidados de sa�de'},;
						{'Z76','Pessoas em contato com os servi�os de sa�de em outras circunst�ncias'},;
						{'Z80','Hist�ria familiar de neoplasia maligna'},;
						{'Z81','Hist�ria familiar de transtornos mentais e comportamentais'},;
						{'Z82','Hist�ria familiar de algumas incapacidades e doen�as cr�nicas que conduzem a incapacita��o'},;
						{'Z83','Hist�ria familiar de outros transtornos espec�ficos'},;
						{'Z84','Hist�ria familiar de outras afec��es'},;
						{'Z85','Hist�ria pessoal de neoplasia maligna'},;
						{'Z86','Hist�ria pessoal de algumas outras doen�as'},;
						{'Z87','Hist�ria pessoal de outras doen�as e afec��es'},;
						{'Z88','Hist�ria pessoal de alergia a drogas, medicamentos e a subst�ncias biol�gicas'},;
						{'Z89','Aus�ncia adquirida de membros'},;
						{'Z90','Aus�ncia adquirida de �rg�os n�o classificados em outra parte'},;
						{'Z91','Hist�ria pessoal de fatores de risco, n�o classificados em outra parte'},;
						{'Z92','Hist�ria pessoal de tratamento m�dico'},;
						{'Z93','Orif�cios artificiais'},;
						{'Z94','�rg�os e tecidos transplantados'},;
						{'Z95','Presen�a de implantes e enxertos card�acos e vasculares'},;
						{'Z96','Presen�a de outros implantes funcionais'},;
						{'Z97','Presen�a de outros dispositivos prot�ticos'},;
						{'Z98','Outros estados p�s-cir�rgicos'},;
						{'Z99','Depend�ncia de m�quinas e dispositivos capacitantes, n�o classificados em outra parte'},;
						{'U04','S�ndrome respirat�ria aguda grave [severe acute respiratory syndrome SARS]'},;
						{'U07','Diagn�stico de doen�a respirat�ria aguda pelo 2019-nCoV [COVID-19]'},;
						{'U80','Agente resistente � penicilina e antibi�ticos relacionados'},;
						{'U81','Agente resistente � vancomicina e antibi�ticos relacionados'},;
						{'U88','Agente resistente a m�ltiplos antibi�ticos'},;
						{'U89','Agente resistente a outros antibi�ticos e a antibi�ticos n�o especificados'},;
						{'U99','CID 10� Revis�o n�o dispon�vel'}}

	Local nY

	dbSelectArea("TLG")
	dbSetOrder(1)
	ProcRegua(Len(aGrupo))
	For nY := 1 to Len(aGrupo)
		IncProc("Processando registros")
		If !dbSeek(xFilial("TLG")+aGrupo[nY][1])
			RecLock("TLG",.T.)
			TLG->TLG_FILIAL:= xFilial("TLG")
			TLG->TLG_GRUPO := aGrupo[nY][1]
			TLG->TLG_DESCRI:= AllTrim(Upper(aGrupo[nY][2]))
			MsUnlock("TLG")
		EndIf
	Next

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional. 

@author Denis Hyroshi de Souza
@since 07/02/07
@return array 
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina :=	{ 	{STR0002, "AxPesqui" , 0, 1},; //"Pesquisar"
							{STR0003, "NGCAD01"	 , 0, 2},; //"Visualizar"
							{STR0004, "NGCAD01"	 , 0, 3},; //"Incluir"
							{STR0005, "NGCAD01"	 , 0, 4},; //"Alterar"
							{STR0006, "NGCAD01"	 , 0, 5, 3}}//"Excluir"

							//Removido, site datasus n�o disponibiliza mais a informa��o
							//{STR0007, "MDT081IMP", 0, 3} } //"Importar" 

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT081IMP
Realiza importacao de arquivo com tabela de Grupos de CID 

@author Roger Rodrigues
@since 20/07/10
@return true
/*/
//---------------------------------------------------------------------
Function MDT081IMP()

	Local nPos
	Local lRetCopy := .F.
	Local cMascara := STR0008 //"CSV(delimitado por v�rgula)     | *.CSV"
	Local cTela
	Local cArqLoc := ""
	Private cArquivo := ""
	Private cPath := GETTEMPPATH()
	Private nSizeTLG := IIf(TamSX3("TLG_DESCRI")[1] < 1, 220, TamSX3("TLG_DESCRI")[1])

	cTela := STR0009 + Chr(13); //"Esta rotina tem como objetivo importar as Categorias do C.I.D. "
			 + STR0010 + Chr(13) + Chr(13); //"via arquivo CSV, disponibilizado no site do www.datasus.gov.br."
			 + STR0011 + Chr(13); //"Antes de confirmar a execu��o do processo, fazer uma c�pia de seguran�a da tabela TLG."
			 + STR0012 + Chr(13) + Chr(13); //"Caso ocorra algum problema durante o processo as c�pias de seguran�a dever�o ser restauradas."
			 + STR0013 + Chr(13) + Chr(13); //"Este processo poder� levar algum tempo para ser executado."
			 + STR0014 //"Deseja efetuar o processamento?"

	If !MsgYesNo(cTELA, STR0015) //"Aten��o"
		Return .T.
	EndIf

	//Seleciona o Arquivo a ser importado
	cArquivo := cGetFile(cMascara, OemToAnsi(STR0016),,,, _OPC_cGETFILE) //"Selecione o arquivo CSV a ser Importado"

	nPos := Rat("\",cArquivo)
	If nPos > 0
		cArqLoc := AllTrim(Subst(cArquivo, nPos + 1,25 ))
	Else
		cArqLoc := cArquivo
	EndIf

	If Right(AllTrim(cPath), 1) != "\"
		cPath += "\"
	EndIf

	If File(cPath+cArqLoc)
		FErase(cPath+cArqLoc)
	EndIf

	//Realiza copia para diretorio temporario
	If At(":", cArquivo) == 0
		lRetCopy := CpyS2T(cArquivo, cPath, .T.)
	Else
		lRetCopy := __CopyFile(cArquivo, cPath + cArqLoc)
	EndIf

	If !lRetCopy
		Return .F.
	EndIf
	
	//Verifica se o arquivo foi copiado
	cArquivo := cPath + cArqLoc
	If !File(cPath + cArqLoc)
		MsgStop(STR0017 + cArquivo + STR0018 + Chr(13) + Chr(13) + STR0019) //"Arquivo "###" n�o encontrado."###"O processo sera cancelado."
		Return .F.
	EndIf

	Processa({ |lEnd| f81ImpCsv()}, STR0020) //"Importando Arquivo"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} f81ImpCsv
Importa arquivo CSV de Grupos de CID

@author Roger Rodrigues
@since 21/07/10
@return true
/*/
//---------------------------------------------------------------------
Static Function f81ImpCsv()
	
	Local nRecno := 0, nPos, i, nAt
	Local cLinha
	Local nHdlArq := fOpen(cArquivo,0)
	Local nTamArq := fSeek(nHdlArq,0,2)
	Local cGrupo := "", cDescri := ""
	Local cGruField := "CAT", cDesField := "DESCRICAO"
	Local nPosGrupo := 1, nPosDescri := 5, nFor := 5

	FT_FUSE(cArquivo)
	FT_FGOTOP()

	ProcRegua(Int(nTamArq/110))

	While (!FT_FEof())
		//Carrega linha do aquivo
		cLinha := AllTrim(FT_FREADLN())

		If Empty(cLinha)//Se for vazio sai da rotina
			Exit
		EndIf
		++ nRecno
		IncProc(STR0021 + AllTrim(Str(nRecno,10))) //"Importando registro: "

		If nRecno == 1 //Verifica Cabecalho
			i := 0
			nPosGrupo := 0
			nPosDescri := 0
			While (nAt := At(";", cLinha)) > 0
				i++
				If AllTrim(Upper(Substr(cLinha, 1, nAt-1))) == cGruField
					nPosGrupo := i
				ElseIf AllTrim(Upper(Substr(cLinha, 1, nAt-1))) == cDesField
					nPosDescri := i
				EndIf
				cLinha := SubStr(cLinha, nAt+1, Len(cLinha))
			End
			If nPosGrupo == 0 .or. nPosDescri == 0
				cTela := STR0022 + Chr(13); //"O arquivo informado para a importa��o � inv�lido."
						 + STR0023 + Chr(13); //"Para o processamento � necess�rio que o cabe�alho(Primeira Linha) "
						 + STR0024 + cGruField + STR0025 + Chr(13); //"do arquivo esteja definindo os campos: '"###"' para o c�digo do Grupo. e "
						 + "'" + cDesField + STR0026 //"' para a descri��o do Grupo."
				MsgStop(cTELA, STR0015) //"Aten��o"
				Return .F.
			EndIf
			//Pula Linha
			FT_FSKIP()
			cLinha := AllTrim(FT_FREADLN())
		EndIf

		nPosAtu := 1
		cGrupo  := ""
		cDescri := ""
		nFor := nPosGrupo
		nFor := If(nFor < nPosDescri, nPosDescri, nFor)
		//Grava variaveis
		For i := 1 To nFor
			nPos := At(";", cLinha)
			nPosAtu := If(nPos == 0, 1, nPos)

			If i == nPosGrupo //Grava Grupo numa variavel
				cGrupo := AllTrim(SubStr(cLinha, 1, nPosAtu-1))
			ElseIf i == nPosDescri
				cDescri := AllTrim(SubStr(cLinha, 1, nPosAtu-1))
				Exit
			EndIf

			If i <> nFor //Verifica se nao e o ultimo processamento
				cLinha := SubStr(cLinha, nPosAtu+1, Len(cLinha))
			EndIf
		Next i

		If !Empty(cGrupo) .and. !Empty(cDescri)
			cGrupo := AllTrim(cGrupo)
			dbSelectArea("TLG")
			dbSetOrder(1)
			If dbSeek(xFilial("TLG") + cGrupo)
				If Padr(Upper(TLG->TLG_DESCRI), nSizeTLG) <> Padr(Upper(cDescri), nSizeTLG)
					RecLock("TLG", .F.)
					TLG->TLG_DESCRI := Upper(Substr(cDescri, 1, 220))
					MsUnlock("TLG")
				Endif
			Else
				RecLock("TLG", .T.)
				TLG->TLG_FILIAL	:= xFilial("TLG")
				TLG->TLG_GRUPO	:= cGrupo
				TLG->TLG_DESCRI := Upper(Substr(cDescri,1,220))
				MsUnlock("TLG")
			Endif
		Endif
		FT_FSKIP()
	End

	FT_FUSE()

	fClose(nHdlArq)

	MsgInfo(STR0027) //"Importa��o conclu�da com sucesso!"

	dbSelectArea("TLG")
	dbGoTop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT081WHEN
Verifica propriedade WHEN do campo passado como par�metro.

@param cCpo - Campo a ser verificado a propriedade WHEN
@return lRet - .T. se permitir edi��o, .F. caso contr�rio

@author Thiago Henrique dos Santos
@since 25/04/2013
/*/
//---------------------------------------------------------------------
Function MDT081WHEN(cCpo)

	Local lRet := .T.

	If SuperGetMV("MV_NG2SEG", .F., "2") == "1" .And. ALTERA .And. Alltrim(cCpo) == "TLG_DESCRI"

		//TMT - Digagn�sticos
		DbSelectArea("TMT")
		TMT->(DbSetOrder(11)) //TMT_GRPCID
		If TMT->(DbSeek(xFilial("TMT") + M->TLG_GRUPO))
			lRet := .F.
		Else
			TMT->(DbSetOrder(12)) //TMT_GRPCI2
			If TMT->(DbSeek(xFilial("TMT") + M->TLG_GRUPO))
				lRet := .F.
			Else
				//TNY - Atestados M�dicos
				DbSelectArea("TNY")
				TNY->(DbSetOrder(7))
				If TNY->(DbSeek(xFilial("TNY") + M->TLG_GRUPO))
					lRet := .F.
				Else
					//TNC - Acidente
					DbSelectArea("TNC")
					TNC->(DbSetOrder(11))
					If TNC->(DbSeek(xFilial("TNC") + M->TLG_GRUPO))
						lRet := .F.
					Else
						//TKI - CID Complementar para Atestado
						DbSelectArea("TKI")
						TKI->(DbSetOrder(3))
						If TKI->(DbSeek(xFilial("TKI")+M->TLG_GRUPO))
							lRet := .F.
						Else
							//TKJ - CID Complementar para Diagnostico
							DbSelectArea("TKJ")
							TKJ->(DbSetOrder(3))
							If TKJ->(DbSeek(xFilial("TKJ")+M->TLG_GRUPO))
								lRet := .F.
							Else
								//TKK - CID Complementar para Acidentes
								DbSelectArea("TKK")
								TKK->(DbSetOrder(3))
								lRet := !TKK->(DbSeek(xFilial("TKK")+M->TLG_GRUPO))
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
