/*
 * generated by Xtext
 */
package com.github.jknack.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.core.runtime.Path
import com.google.inject.Inject
import org.osgi.framework.Bundle
import org.eclipse.core.resources.IWorkspaceRoot
import com.github.jknack.console.ConsoleListener
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Status

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class Antlr4Generator implements IGenerator {
  @Inject
  Bundle bundle

  @Inject
  ToolOptionsProvider optionsProvider

  @Inject
  ConsoleListener console

  @Inject
  IWorkspaceRoot workspaceRoot

  override void doGenerate(Resource resource, IFileSystemAccess fsa) {
    val file = workspaceRoot.getFile(new Path(resource.getURI().toPlatformString(true)))
    doGenerate(file, optionsProvider.options(file))
  }

  def void generate(IFile file, ToolOptions options) {
    Jobs.schedule("Building " + file.name) [monitor|
      doGenerate(file, options)
      return Status.OK_STATUS
    ]
  }

  private def void doGenerate(IFile file, ToolOptions config) {
    val project = file.project
    val monitor = new NullProgressMonitor()

    new ToolRunner(bundle).run(file, config, console)

    project.refreshLocal(IResource.DEPTH_INFINITE, monitor)
    val output = config.output(file)
    if (project.exists(output.relative)) {
      val folder = project.getFolder(output.relative)

      /**
       * Mark files as derived
       */
      folder.accept [ generated |
        generated.setDerived(config.derived, monitor)
        return true
      ]
    }
  }

}
