﻿// Copyright (c) Microsoft Corporation. All rights reserved. See License.txt in the project root for license information.

using Microsoft.Practices.EnterpriseLibrary.SemanticLogging.Etw;
using Microsoft.Practices.EnterpriseLibrary.SemanticLogging.Etw.Configuration;
using Microsoft.Practices.EnterpriseLibrary.SemanticLogging.Tests.TestSupport;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Microsoft.Practices.EnterpriseLibrary.SemanticLogging.Tests.Etw
{
    using Microsoft.Practices.EnterpriseLibrary.SemanticLogging.Configuration;

    [TestClass]
    public class given_traceEventServiceSettings_configuration
    {
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void when_creating_instance_with_null_sessionName()
        {
            new TraceEventServiceSettings() { SessionNamePrefix = null };
        }

        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void when_creating_instance_with_empty_sessionName()
        {
            new TraceEventServiceSettings() { SessionNamePrefix = string.Empty };
        }

        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void when_creating_instance_with_max_sessionName_length()
        {
            new TraceEventServiceSettings() { SessionNamePrefix = new string('a', 201) };
        }

        [TestMethod]
        public void when_creating_instance_with_default_values()
        {
            var sut = new TraceEventServiceSettings();

            Assert.IsTrue(sut.SessionNamePrefix.StartsWith(Constants.DefaultSessionNamePrefix));
        }
    }
}
